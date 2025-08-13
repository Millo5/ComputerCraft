local egroups = {
    ReactiveNonMetals = colors.gold,
    AlkaliMetals = colors.pink,
    AlkalineEarthMetals = colors.red,
    TransitionMetals = colors.white,
    PostTransitionMetals = colors.blue,
    Metalloids = colors.lime,
    Halogens = colors.magenta,
    NobleGases = colors.cyan,
    Lanthanides = colors.orange,
    Actinides = colors.green
}

local Element = {}
Element.__index = Element

function Element.new(symbol, name, group)
    local self = setmetatable({}, Element)
    self.symbol = symbol
    self.name = name
    self.group = group or egroups.ReactiveNonMetals
    return self
end

function Element:printToMonitor(monitor, x, y)
    monitor.setCursorPos(x, y)
    monitor.setTextColor(self.group)
    monitor.write(self.symbol)
    monitor.setTextColor(colors.white)
end

PeriodicTable = {
    elements = {
        -- 1–10
        Element.new("H",  "hydrogen", egroups.ReactiveNonMetals),
        Element.new("He", "helium",   egroups.NobleGases),
        Element.new("Li", "lithium",  egroups.AlkaliMetals),
        Element.new("Be", "beryllium",egroups.AlkalineEarthMetals),
        Element.new("B",  "boron",    egroups.Metalloids),
        Element.new("C",  "carbon",   egroups.ReactiveNonMetals),
        Element.new("N",  "nitrogen", egroups.ReactiveNonMetals),
        Element.new("O",  "oxygen",   egroups.ReactiveNonMetals),
        Element.new("F",  "fluorine", egroups.Halogens),
        Element.new("Ne", "neon",     egroups.NobleGases),

        -- 11–20
        Element.new("Na", "sodium",   egroups.AlkaliMetals),
        Element.new("Mg", "magnesium",egroups.AlkalineEarthMetals),
        Element.new("Al", "aluminium",egroups.PostTransitionMetals),
        Element.new("Si", "silicon",  egroups.Metalloids),
        Element.new("P",  "phosphorus",egroups.ReactiveNonMetals),
        Element.new("S",  "sulfur",   egroups.ReactiveNonMetals),
        Element.new("Cl", "chlorine", egroups.Halogens),
        Element.new("Ar", "argon",    egroups.NobleGases),
        Element.new("K",  "potassium",egroups.AlkaliMetals),
        Element.new("Ca", "calcium",  egroups.AlkalineEarthMetals),

        -- 21–30
        Element.new("Sc", "scandium", egroups.TransitionMetals),
        Element.new("Ti", "titanium", egroups.TransitionMetals),
        Element.new("V",  "vanadium", egroups.TransitionMetals),
        Element.new("Cr", "chromium", egroups.TransitionMetals),
        Element.new("Mn", "manganese",egroups.TransitionMetals),
        Element.new("Fe", "iron",     egroups.TransitionMetals),
        Element.new("Co", "cobalt",   egroups.TransitionMetals),
        Element.new("Ni", "nickel",   egroups.TransitionMetals),
        Element.new("Cu", "copper",   egroups.TransitionMetals),
        Element.new("Zn", "zinc",     egroups.TransitionMetals),

        -- 31–40
        Element.new("Ga", "gallium",  egroups.PostTransitionMetals),
        Element.new("Ge", "germanium",egroups.Metalloids),
        Element.new("As", "arsenic",  egroups.Metalloids),
        Element.new("Se", "selenium", egroups.ReactiveNonMetals),
        Element.new("Br", "bromine",  egroups.Halogens),
        Element.new("Kr", "krypton",  egroups.NobleGases),
        Element.new("Rb", "rubidium", egroups.AlkaliMetals),
        Element.new("Sr", "strontium",egroups.AlkalineEarthMetals),
        Element.new("Y",  "yttrium",  egroups.TransitionMetals),
        Element.new("Zr", "zirconium",egroups.TransitionMetals),

        -- 41–50
        Element.new("Nb", "niobium",  egroups.TransitionMetals),
        Element.new("Mo", "molybdenum",egroups.TransitionMetals),
        Element.new("Tc", "technetium",egroups.TransitionMetals),
        Element.new("Ru", "ruthenium",egroups.TransitionMetals),
        Element.new("Rh", "rhodium",  egroups.TransitionMetals),
        Element.new("Pd", "palladium",egroups.TransitionMetals),
        Element.new("Ag", "silver",   egroups.TransitionMetals),
        Element.new("Cd", "cadmium",  egroups.TransitionMetals),
        Element.new("In", "indium",   egroups.PostTransitionMetals),
        Element.new("Sn", "tin",      egroups.PostTransitionMetals),

        -- 51–60
        Element.new("Sb", "antimony", egroups.Metalloids),
        Element.new("Te", "tellurium",egroups.Metalloids),
        Element.new("I",  "iodine",   egroups.Halogens),
        Element.new("Xe", "xenon",    egroups.NobleGases),
        Element.new("Cs", "cesium",   egroups.AlkaliMetals),
        Element.new("Ba", "barium",   egroups.AlkalineEarthMetals),
        Element.new("La", "lanthanum",egroups.Lanthanides),
        Element.new("Ce", "cerium",   egroups.Lanthanides),
        Element.new("Pr", "praseodymium",egroups.Lanthanides),
        Element.new("Nd", "neodymium",egroups.Lanthanides),

        -- 61–70
        Element.new("Pm", "promethium",egroups.Lanthanides),
        Element.new("Sm", "samarium", egroups.Lanthanides),
        Element.new("Eu", "europium", egroups.Lanthanides),
        Element.new("Gd", "gadolinium",egroups.Lanthanides),
        Element.new("Tb", "terbium",  egroups.Lanthanides),
        Element.new("Dy", "dysprosium",egroups.Lanthanides),
        Element.new("Ho", "holmium",  egroups.Lanthanides),
        Element.new("Er", "erbium",   egroups.Lanthanides),
        Element.new("Tm", "thulium",  egroups.Lanthanides),
        Element.new("Yb", "ytterbium",egroups.Lanthanides),

        -- 71–80
        Element.new("Lu", "lutetium", egroups.Lanthanides),
        Element.new("Hf", "hafnium",  egroups.TransitionMetals),
        Element.new("Ta", "tantalum", egroups.TransitionMetals),
        Element.new("W",  "tungsten", egroups.TransitionMetals),
        Element.new("Re", "rhenium",  egroups.TransitionMetals),
        Element.new("Os", "osmium",   egroups.TransitionMetals),
        Element.new("Ir", "iridium",  egroups.TransitionMetals),
        Element.new("Pt", "platinum", egroups.TransitionMetals),
        Element.new("Au", "gold",     egroups.TransitionMetals),
        Element.new("Hg", "mercury",  egroups.TransitionMetals),

        -- 81–90
        Element.new("Tl", "thallium", egroups.PostTransitionMetals),
        Element.new("Pb", "lead",     egroups.PostTransitionMetals),
        Element.new("Bi", "bismuth",  egroups.PostTransitionMetals),
        Element.new("Po", "polonium", egroups.Metalloids),
        Element.new("At", "astatine", egroups.Halogens),
        Element.new("Rn", "radon",    egroups.NobleGases),
        Element.new("Fr", "francium", egroups.AlkaliMetals),
        Element.new("Ra", "radium",   egroups.AlkalineEarthMetals),
        Element.new("Ac", "actinium", egroups.Actinides),
        Element.new("Th", "thorium",  egroups.Actinides),

        -- 91–100
        Element.new("Pa", "protactinium",egroups.Actinides),
        Element.new("U",  "uranium",  egroups.Actinides),
        Element.new("Np", "neptunium",egroups.Actinides),
        Element.new("Pu", "plutonium",egroups.Actinides),
        Element.new("Am", "americium",egroups.Actinides),
        Element.new("Cm", "curium",   egroups.Actinides),
        Element.new("Bk", "berkelium",egroups.Actinides),
        Element.new("Cf", "californium",egroups.Actinides),
        Element.new("Es", "einsteinium",egroups.Actinides),
        Element.new("Fm", "fermium",  egroups.Actinides),

        -- 101–110
        Element.new("Md", "mendelevium",egroups.Actinides),
        Element.new("No", "nobelium", egroups.Actinides),
        Element.new("Lr", "lawrencium",egroups.Actinides),
        Element.new("Rf", "rutherfordium",egroups.TransitionMetals),
        Element.new("Db", "dubnium",  egroups.TransitionMetals),
        Element.new("Sg", "seaborgium",egroups.TransitionMetals),
        Element.new("Bh", "bohrium",  egroups.TransitionMetals),
        Element.new("Hs", "hassium",  egroups.TransitionMetals),
        Element.new("Mt", "meitnerium",egroups.TransitionMetals),
        Element.new("Ds", "darmstadtium",egroups.TransitionMetals),

        -- 111–118
        Element.new("Rg", "roentgenium",egroups.TransitionMetals),
        Element.new("Cn", "copernicium",egroups.TransitionMetals),
        Element.new("Nh", "nihonium", egroups.PostTransitionMetals),
        Element.new("Fl", "flerovium",egroups.PostTransitionMetals),
        Element.new("Mc", "moscovium",egroups.PostTransitionMetals),
        Element.new("Lv", "livermorium",egroups.PostTransitionMetals),
        Element.new("Ts", "tennessine",egroups.Halogens),
        Element.new("Og", "oganesson",egroups.NobleGases),
    }
}
