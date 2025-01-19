import Gameboy from 'serverboy';
import { readFileSync } from 'fs';
import WebSocket from 'ws';


const rom = readFileSync("./src/roms/crystal.gbc")

const gameboy = new Gameboy();

gameboy.loadRom(rom);

setInterval(() => {

    gameboy.doFrame();
    console.log(gameboy.getScreen());

}, 1000 / 30);

const wss = new WebSocket.Server({ port: 5773 });

wss.on('connection', ws => {
    ws.on('message', message => {
        console.log(`Received message => ${message}`)
    });

    ws.send('Hello! Message From Server!!');
});
