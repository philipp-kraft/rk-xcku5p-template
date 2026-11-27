# Bitstream: build/<top>_route.dcp -> build/<top>.bit
#
#   scripts/vivado.sh scripts/bit.tcl <top>
#
# Refuses to write a bitstream if timing isn't met.

lassign $argv top
if {$top eq ""} {
    error "usage: bit.tcl <top>"
}

set root [file normalize [file join [file dirname [info script]] ..]]
cd [file join $root build]

open_checkpoint ${top}_route.dcp

set wns [get_property SLACK [get_timing_paths -delay_type max]]
set whs [get_property SLACK [get_timing_paths -delay_type min]]
puts "Timing: WNS = $wns ns, WHS = $whs ns"
if {($wns ne "" && $wns < 0) || ($whs ne "" && $whs < 0)} {
    error "timing not met, see build/reports/timing_summary.rpt"
}

write_bitstream -force ${top}.bit
puts "Bitstream: [file join [pwd] ${top}.bit]"
