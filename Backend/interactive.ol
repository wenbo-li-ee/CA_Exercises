
package require openlane
prep -design . -ignore_mismatches -tag 250430-144651_SOLUTION3_pipeline_basic_MULT2
set_odb ./runs/250430-144651_SOLUTION3_pipeline_basic_MULT2/results/floorplan/cpu.odb
set_def ./runs/250430-144651_SOLUTION3_pipeline_basic_MULT2/results/floorplan/cpu.def
or_gui
