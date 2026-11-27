# Synthesis: rtl/*.sv + constraints/*.xdc -> build/<top>_synth.dcp
#
#   scripts/vivado.sh scripts/synth.tcl <top> <part>

lassign $argv top part
if {$top eq "" || $part eq ""} {
    error "usage: synth.tcl <top> <part>"
}

set root [file normalize [file join [file dirname [info script]] ..]]
file mkdir [file join $root build reports]
cd [file join $root build]

set_part $part
read_verilog -sv [lsort [glob -directory [file join $root rtl] *.sv]]
read_xdc         [lsort [glob -directory [file join $root constraints] *.xdc]]

synth_design -top $top -part $part

report_utilization    -file reports/synth_utilization.rpt
report_timing_summary -file reports/synth_timing_summary.rpt -max_paths 10

write_checkpoint -force ${top}_synth.dcp
