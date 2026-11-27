# rk-xcku5p-template

SystemVerilog starter template for the **RK-XCKU5P-F V1.2** board, built around
an AMD Kintex UltraScale+ `xcku5p-ffvb676-2-i`, with a script-driven Vivado flow.

## Usage

Tested with Vivado 2026.2 on Debian 13 (WSL2).

Put `vivado` on your PATH, then:

```sh
make synth      # synthesize      -> build/<top>_synth.dcp
make impl       # place and route -> build/<top>_route.dcp
make            # bitstream       -> build/<top>.bit
make program    # load it over JTAG
make gui        # open the newest checkpoint in the Vivado GUI
make clean
```

Make reruns only the stages whose inputs changed. Use `TOP=<module>` to build
another top. Reports and logs go to `build/`.

## Demo (`top`)

- `led[3:0]` show a 4-bit counter: `key[0]` up, `key[1]` down, `key[2]` reset
- `key[3]` sets the counter to its max (15)

## WSL2 setup

The board's USB (FT2232H, `0403:6010`) carries JTAG and UART. Pass it to WSL with
[usbipd-win](https://github.com/dorssel/usbipd-win):

```powershell
usbipd bind --hardware-id 0403:6010                          # once, admin
usbipd attach --wsl --hardware-id 0403:6010 --auto-attach    # each session
```

Once in WSL, install the cable udev rules:

```sh
sudo /opt/AMD/2026.2/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers
```

## Layout

```
rtl/          SystemVerilog, every *.sv is read
constraints/  XDC, every *.xdc is read
tb/           testbenches
scripts/      vivado.sh runs one Tcl script per stage
build/        all output (git-ignored)
```
