# Program build/<top>.bit into the FPGA over JTAG (volatile, lost on power cycle)
#
#   scripts/vivado.sh scripts/program.tcl <top>
#
# Connects to the local hw_server (Vivado starts it if needed).

lassign $argv top
if {$top eq ""} {
    error "usage: program.tcl <top>"
}

set root [file normalize [file join [file dirname [info script]] ..]]
set bit  [file join $root build $top.bit]
if {![file exists $bit]} {
    error "$bit not found, run `make bitstream` first"
}
cd [file join $root build]

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

set dev [lindex [get_hw_devices -quiet xcku5p*] 0]
if {$dev eq ""} {
    error "no xcku5p on the JTAG chain (found: [get_hw_devices -quiet])"
}
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev

set_property PROBES.FILE      {}   $dev
set_property FULL_PROBES.FILE {}   $dev
set_property PROGRAM.FILE     $bit $dev
program_hw_devices $dev

puts "Programmed $dev with $bit"
close_hw_target
disconnect_hw_server
close_hw_manager
