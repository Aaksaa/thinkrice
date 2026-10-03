<p align="center">
  <img src="./assets/thinkrice.svg" width="900" alt="thinkrice-icon">
</p>

# ThinkRice

A collection of configurations and assets for ricing. This project focuses on terminal appearance, Lenovo/ThinkPad visual identity, and ThinkPad-themed wallpapers.

## Project contents

| Component     | Description                                             |
| ------------- | ------------------------------------------------------- |
| `fastfetch/`  | Fastfetch configuration and ThinkPad/Lenovo ASCII logos |
| `neofetch/`   | ASCII logos that can be used with Neofetch              |
| `wallpapers/` | Collection of ThinkPad-themed wallpapers                |

### Fastfetch

Several configurations are available:

- `fastfetch/ascii` - contains ASCII logos that can be called through the Neofetch configuration, including several variations of ThinkPad, Lenovo, ThinkCentre, and ThinkServer logos.
- `fastfetch/configs` - several examples of ready-to-use configurations for fastfetch.

The configuration displays information such as device, CPU, GPU, memory, disk, operating system, kernel, shell, desktop environment/window manager, uptime, date, and system installation age.

Before installing, you can check [this page](./fastfetch/README.md) first.

### Neofetch

The `neofetch/ascii/` directory contains ASCII logos that can be called through the Neofetch configuration, including several variations of ThinkPad, Lenovo, ThinkCentre, and ThinkServer logos.

And be added another configs for neofetch.

### Wallpaper

The `wallpapers/` directory contains ThinkPad-themed PNG wallpapers. Will be added another wallaper soon.

## Requirements

- Linux or a Unix-like system.
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) or [Neofetch](https://github.com/dylanaraps/neofetch).
- A Nerd Font so that icons in the terminal output display correctly. (optional)

## Installation

You can install manually with gitclone, rename the file and copy the file into ~/.config/fastfetch/. Don't forget to renaming the file into config.jsonc. Maybe i will make the install.sh file soon.

## Running Fastfetch

If you want to try the configuration, copy the desired configuration to the active configuration location or run it directly from the project directory.

Example:

```bash
fastfetch --config ./configs/thinkpad-vertical.jsonc
```

If a configuration refers to a different logo file name, change the `logo.source` value to match the file available in `~/.config/fastfetch/ascii/`.

## Using logos with Neofetch

Add or change the following option in `~/.config/neofetch/config.conf`:

```bash
ascii_custom="$HOME/.config/neofetch/ascii/thinkpad-h.txt"
```

Replace `thinkpad-h.txt` with another logo from the `neofetch/ascii/` directory according to your preference.

## Configuration notes

- Some logos use Unicode characters and Nerd Font icons.
- Fastfetch files use the JSONC format, so comments inside them are intentional.
- Fastfetch configurations that use logo paths relative to `~/.config/fastfetch/ascii/` require the ASCII assets to have been copied to that location.
- Wallpapers can be selected through the desktop environment or wallpaper manager you use.

## Customization

1. Choose an ASCII logo from `fastfetch/ascii/` or `neofetch/ascii/`.
2. Change `logo.source` in the Fastfetch configuration.
3. Adjust colors, padding, modules, and output format as needed.
4. Choose a wallpaper from `wallpapers/`.
