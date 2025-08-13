const Gameboy = require('serverboy');
const { readFileSync } = require('fs');
const { WebSocket } = require('ws');
const palette = require("palettext");
const color = require("color");
const { deflateRawSync, inflateRawSync } = require('zlib');


const rom = readFileSync("./src/roms/crystal.gbc")
const gameboy = new Gameboy();
gameboy.loadRom(rom);
const core = gameboy[Object.keys(gameboy)[0]].gameboy;
gbPalette = [];

const WIDTH = 160;
const HEIGHT = 144;

var bytesSent = 0;


// ----------------------------------------------------------------------------------------------------------------------------


const blitColors = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768];

const colorDistance = (r1, g1, b1, r2, g2, b2) => {
    return Math.sqrt((r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2);
}

const findClosest = (r, g, b, colors) => {
    let closest = 0;
    let closestDist = 1000000;
    for (let j = 0; j < colors.length; j++) {
        const [pr, pg, pb] = colors[j];
        const dist = colorDistance(pr, pg, pb, r, g, b);
        if (dist < closestDist) {
            closest = j;
            closestDist = dist;
        }
    }
    return closest;
}

const sendScreenNew = (ws) => {
    console.time("frame");

    const pixels = gameboy.getScreen();
    const colorsBuffer = Buffer.alloc(blitColors.length * 3);

    // console.time('palette');
    let colors = [[0, 0, 0]];
    const seenColors = new Set();
    for (let gbColor of gbPalette) {
        const dec = gbColor & 0xffffff;
        if (seenColors.has(dec)) continue;
        colors.push(dec);
        seenColors.add(dec);
    }
    colors = colors.slice(0, 16).map((c) => color(c).rgb().array());

    for (let i = 0; i < blitColors.length; i++) {
        let c = 0;
        if (colors[i]) {
            c = colors[i][0] << 16 | colors[i][1] << 8 | colors[i][2];
        }
        colorsBuffer.writeUIntBE(c, i * 3, 3);
    }

    // Converts (2, 3) pixels into one character with a foreground and background color
    // Arguments are between 0 and 15
    const constructCompact = (a, b, c, d, e, f) => {
        /*
        Format:
          a b
          c d
          e f
        */

        // f HAS TO BE THE BACKGROUND
    
        const all = [a, b, c, d, e, f];
    
        const countMap = Array(16).fill(0);
        all.forEach((c) => {
            countMap[c] += 1;
        });
    
        const sorted = countMap.map((_, i) => i).sort((a, b) => countMap[b] - countMap[a]);
        let primary = sorted[0]; // Background
        let secondary = sorted[1]; // Foreground

        const nearest = all.map((c) => {
            if (c === primary) return primary;
            if (c === secondary) return secondary;

            // Find the nearest color
            const [r, g, b] = colors[c];
            return findClosest(r, g, b, [colors[primary], colors[secondary]]);
        })

        // Build the character
        let char = 128;
        [a, b, c, d, e, f] = nearest;

        // Make sure f is the background
        if (f !== primary) {
            const temp = primary;
            primary = secondary;
            secondary = temp;
        }

        if (a === secondary) char += 1;
        if (b === secondary) char += 2;
        if (c === secondary) char += 4;
        if (d === secondary) char += 8;
        if (e === secondary) char += 16;

        const background = primary;
        const foreground = secondary;
        return { char, foreground, background };
    }

    const blitBuffer = Buffer.alloc(HEIGHT * WIDTH / 2);
    const colBuffer = Buffer.alloc(HEIGHT * WIDTH / 2);

    // console.time('blit');
    const colorsClosestCompatible = colors.map((c) => c.color);
    for (let y = 0; y < HEIGHT; y += 3) {
        for (let x = 0; x < WIDTH; x += 2) {
            const i = y * WIDTH + x;
            const { char, foreground, background } = constructCompact(
                findClosest(pixels[i * 4], pixels[i * 4 + 1], pixels[i * 4 + 2], colors),
                findClosest(pixels[i * 4 + 4], pixels[i * 4 + 5], pixels[i * 4 + 6], colors),
                findClosest(pixels[i * 4 + WIDTH * 4], pixels[i * 4 + WIDTH * 4 + 1], pixels[i * 4 + WIDTH * 4 + 2], colors),
                findClosest(pixels[i * 4 + WIDTH * 4 + 4], pixels[i * 4 + WIDTH * 4 + 5], pixels[i * 4 + WIDTH * 4 + 6], colors),
                findClosest(pixels[i * 4 + WIDTH * 8], pixels[i * 4 + WIDTH * 8 + 1], pixels[i * 4 + WIDTH * 8 + 2], colors),
                findClosest(pixels[i * 4 + WIDTH * 8 + 4], pixels[i * 4 + WIDTH * 8 + 5], pixels[i * 4 + WIDTH * 8 + 6], colors)
            );

            const charColors = foreground << 4 | background;
            // blitStr += String.fromCharCode(char);
            // colStr += String.fromCharCode(charColors);
            blitBuffer.writeUInt8(char, (y / 3) * WIDTH / 2 + x / 2);
            colBuffer.writeUInt8(charColors, (y / 3) * WIDTH / 2 + x / 2);
        }

        // blitStr += '\n';
        // colStr += '\n'; // Keep the same length
    }
    // console.timeEnd('blit');

    // const toSend = Buffer.concat([colorsBuffer, Buffer.from(str)]);
    // const toSend = Buffer.concat([colorsBuffer, Buffer.from(blitStr), Buffer.from(colStr)]);
    const toSend = Buffer.concat([colorsBuffer, blitBuffer, colBuffer]);
    if (ws) ws.send(toSend);

    const byteCount = toSend.byteLength;
    bytesSent += byteCount;

    const mb = bytesSent / 1024 / 1024;
    process.stdout.write(`\rBytes sent: ${mb.toFixed(2)} MB\n`);
    console.timeEnd("frame");
}


const wss = new WebSocket.Server({ port: 50505 });
let socket = null;
let ack = false;
const keysPressed = Array(8).fill(0);

// sendScreenNew(null);

setInterval(() => {

    if (socket) {

        for (let i = 0; i < keysPressed.length; i++) {
            if (keysPressed[i] > 0) {
                keysPressed[i] -= 1;
                gameboy.pressKey(i);
            }
        }

        gameboy.doFrame();
        gameboy.doFrame();
        gameboy.doFrame();
        gameboy.doFrame();
        gbPalette = [...core.gbcOBJPalette, ...core.gbcBGPalette];
        // console.log(gbPalette);
        if (ack) {
            ack = false;
            sendScreenNew(socket);
        }
    // socket = null;
    }

}, 1000 / 60);

wss.on('connection', ws => {
    socket = ws;

    // sendScreen(ws);

    console.log('Client connected');

    ws.send('hello');

    ws.on('close', () => {
        if (socket === ws) {
            socket = null;
            console.log('Client disconnected');
        }
    })

    ws.on('message', (message) => {
        if (message == 'ACK') {
            ack = true;
        } else {
            console.log(` Received message: ${message}`);
            // gameboy.pressKey(+message)
            // keysPressed.add(+message);
            keysPressed[+message] = 3;
        }
    })

});


console.log('Server running on ws://localhost:50505');
// wss://26fd-81-207-247-206.ngrok-free.app


