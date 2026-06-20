var colors = {
    rosewater: "#f5e0dc",
    flamingo: "#f2cdcd",
    pink: "#f5c2e7",
    mauve: "#cba6f7",
    red: "#f38ba8",
    maroon: "#eba0ac",
    peach: "#fab387",
    yellow: "#f9e2af",
    green: "#a6e3a1",
    teal: "#94e2d5",
    sky: "#89dceb",
    sapphire: "#74c7ec",
    blue: "#89b4fa",
    lavender: "#b4befe",
    textcolor: "#cdd6f4",
    subtext1: "#bac2de",
    subtext0: "#a6adc8",
    overlay2: "#9399b2",
    overlay1: "#7f849c",
    overlay0: "#6c7086",
    surface2: "#585b70",
    surface1: "#45475a",
    surface0: "#313244",
    base: "#1e1e2e",
    mantle: "#181825",
    crust: "#11111b",
};

var font_family = "JetBrainsMono Nerd Font";
var font_size = 15;

var bar = {
    workspace_color: colors.blue,
    cpu_color: colors.red,
    ram_color: colors.lavender,
    ram_danager_color: colors.peach,
    clock_color: colors.mauve,

    ram_danager_level: 75,
    ram_danager_label:
        "!!! DANGER RAM USAGE APPROCHING A LEVEL WHERE THE SYSTEM WILL BEGIN TO CLOSE PROGRAMS !!! usage: ",
    submapcolors: {
        NORMAL: colors.green,
        RESIZE: colors.peach,
        MOVE: colors.yellow,
        SESSION: colors.lavender,
    },
};

var notifications = {
    timeout: 5000, // In Miliseconds
};
