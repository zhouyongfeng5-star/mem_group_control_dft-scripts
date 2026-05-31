########################################################################
# Memory group DFT hookup script
#
# Function:
# 1. Parse a flat mem_group list:
#      [list \
#          C1 /path/to/mema \
#          C1 /path/to/memb \
#          C2 /path/to/memc \
#          ... \
#      ]
# 2. Count the number of instances in each group and find the largest one
# 3. Create TDR signals based on the largest group size:
#      DS0 DS1 DS2 ...
#      LS0 LS1 LS2 ...
# 4. Traverse instances in each group and hook pins by slot index:
#      slot 0 -> DS0 / LS0
#      slot 1 -> DS1 / LS1
#      ...
# 5. Print a command-line table and generate a CSV report under rpt
########################################################################

########################################################################
# Required input variables
#
# 1. mem_group:
#    Flat list containing group/instance pairs
#
# 2. mem_group_testpins:
#    Pin list to be processed, must be provided by user
#
# 3. mem_group_rpt_dir:
#    Report output directory, must be provided by user
########################################################################

########################################################################
# User configuration area
#
# Edit the variables below before sourcing this script.
# If these variables are already defined by an upper-level flow, you can
# keep this section commented out and let the flow pass them in.
#
# Example:
#
# set mem_group [list \
#     C1 /da/dad/ada/mema \
#     C1 /dsad/dsad/memb \
#     C2 /top/memc \
#     C2 /top/memd \
# ]
#
# set mem_group_testpins {DS LS}
# set mem_group_rpt_dir "./rpt"
########################################################################

if {![info exists mem_group]} {
    error "variable mem_group is not defined"
}

if {![info exists mem_group_testpins]} {
    error "variable mem_group_testpins is not defined"
}

if {![info exists mem_group_rpt_dir]} {
    error "variable mem_group_rpt_dir is not defined"
}

########################################################################
# Utility proc:
# escape embedded double quotes for CSV fields
########################################################################
proc csv_escape {value} {
    regsub -all {"} $value {""} value
    return "\"$value\""
}

########################################################################
# Step 1: validate mem_group format
########################################################################
if {[expr {[llength $mem_group] % 2}] != 0} {
    error "mem_group must contain group/instance pairs; current list length is odd"
}

########################################################################
# Step 2: parse mem_group into group -> instance list mapping
########################################################################
array unset group_to_instances
set group_name_list {}

foreach {group_name instance_name} $mem_group {
    if {![info exists group_to_instances($group_name)]} {
        set group_to_instances($group_name) {}
        lappend group_name_list $group_name
    }
    lappend group_to_instances($group_name) $instance_name
}

########################################################################
# Step 3: find the largest group size
########################################################################
set max_group_size 0
set max_group_name ""

foreach group_name $group_name_list {
    set group_size [llength $group_to_instances($group_name)]
    if {$group_size > $max_group_size} {
        set max_group_size $group_size
        set max_group_name $group_name
    }
}

if {$max_group_size == 0} {
    error "mem_group is empty after parsing"
}

puts "INFO: parsed [llength $group_name_list] groups"
puts "INFO: largest group is $max_group_name, size = $max_group_size"

########################################################################
# Step 4: create 0..max_group_size-1 TDR signals for each pin
########################################################################
set mem_group_tdr_signal_list {}

foreach pin $mem_group_testpins {
    for {set idx 0} {$idx < $max_group_size} {incr idx} {
        lappend mem_group_tdr_signal_list "${pin}${idx}"
    }
}

register_static_dft_signal_names $mem_group_tdr_signal_list
add_dft_signals $mem_group_tdr_signal_list -create_with_tdr

########################################################################
# Step 5: traverse instances, query pins, and hook them up
########################################################################
set hookup_report {}

foreach group_name $group_name_list {
    set instance_list $group_to_instances($group_name)

    for {set idx 0} {$idx < [llength $instance_list]} {incr idx} {
        set instance_name [lindex $instance_list $idx]

        foreach pin $mem_group_testpins {
            set tdr_signal_name "${pin}${idx}"
            set pin_collection [get_pins [list $pin] -of_instance $instance_name -silent]
            set pin_count [sizeof_collection $pin_collection]

            if {$pin_count == 0} {
                set report_row [list $group_name $idx $instance_name $pin "" $tdr_signal_name "SKIP" "pin_not_found"]
                lappend hookup_report $report_row
                continue
            }

            set pin_full_path "${instance_name}/${pin}"
            add_dft_control_point $pin_full_path -dft_signal_source_name $tdr_signal_name
            puts "INFO: add_dft_control_point $pin_full_path -dft_signal_source_name $tdr_signal_name"

            set report_row [list $group_name $idx $instance_name $pin $pin_full_path $tdr_signal_name "HOOKED" "ok"]
            lappend hookup_report $report_row
        }
    }
}

########################################################################
# Step 6: print command-line table
########################################################################
puts ""
puts "================ Memory Group DFT Hookup Report ================"
puts [format "%-8s %-6s %-40s %-10s %-50s %-14s %-10s %-14s" \
    GROUP SLOT INSTANCE PIN PIN_FULL_PATH TDR_SIGNAL STATUS NOTE]
puts [string repeat "-" 164]

foreach row $hookup_report {
    set group_name      [lindex $row 0]
    set idx             [lindex $row 1]
    set instance_name   [lindex $row 2]
    set pin             [lindex $row 3]
    set pin_full_path   [lindex $row 4]
    set tdr_signal_name [lindex $row 5]
    set status          [lindex $row 6]
    set note            [lindex $row 7]
    puts [format "%-8s %-6s %-40s %-10s %-50s %-14s %-10s %-14s" $group_name $idx $instance_name $pin $pin_full_path $tdr_signal_name $status $note]
}

########################################################################
# Step 7: write CSV to rpt directory
########################################################################
file mkdir $mem_group_rpt_dir
set mem_group_csv_file [file join $mem_group_rpt_dir "mem_group_dft_hookup_report.csv"]

set fp [open $mem_group_csv_file w]
puts $fp "group_name,slot_index,instance_name,pin_name,pin_full_path,tdr_signal_name,status,note"

foreach row $hookup_report {
    set group_name      [lindex $row 0]
    set idx             [lindex $row 1]
    set instance_name   [lindex $row 2]
    set pin             [lindex $row 3]
    set pin_full_path   [lindex $row 4]
    set tdr_signal_name [lindex $row 5]
    set status          [lindex $row 6]
    set note            [lindex $row 7]
    set csv_fields [list [csv_escape $group_name] [csv_escape $idx] [csv_escape $instance_name] [csv_escape $pin] [csv_escape $pin_full_path] [csv_escape $tdr_signal_name] [csv_escape $status] [csv_escape $note]]
    puts $fp [join $csv_fields ","]
}

close $fp

puts ""
puts "INFO: CSV report written to $mem_group_csv_file"

########################################################################
# Demo:
#
# set mem_group [list \
#     C1 /da/dad/ada/mema \
#     C1 /dsad/dsad/memb \
#     C2 dsadada_memc \
#     C2 ppppppp_memd \
# ]
#
# set mem_group_testpins {DS LS}
# set mem_group_rpt_dir "./rpt"
# source mem_group_dft_setup.tcl
########################################################################
