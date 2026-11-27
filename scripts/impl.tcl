# Implementation: build/<top>_synth.dcp -> opt/place/route -> build/<top>_route.dcp
#
#   scripts/vivado.sh scripts/impl.tcl <top>
#
# Always writes the routed checkpoint, even if timing fails, so the result
# can be inspected. bit.tcl refuses to write a bitstream if timing failed.

lassign $argv top
if {$top eq ""} {
    error "usage: impl.tcl <top>"
}

set root [file normalize [file join [file dirname [info script]] ..]]
file mkdir [file join $root build reports]
cd [file join $root build]

open_checkpoint ${top}_synth.dcp

opt_design
place_design
phys_opt_design
route_design

report_timing_summary -file reports/timing_summary.rpt -max_paths 10
report_utilization       -file reports/utilization.rpt
report_clock_utilization -file reports/clock_utilization.rpt
report_drc               -file reports/drc.rpt
report_methodology       -file reports/methodology.rpt
report_io                -file reports/io.rpt
report_power             -file reports/power.rpt

set wns [get_property SLACK [get_timing_paths -delay_type max]]
set whs [get_property SLACK [get_timing_paths -delay_type min]]
puts "Timing: WNS = $wns ns, WHS = $whs ns"

write_checkpoint -force ${top}_route.dcp
