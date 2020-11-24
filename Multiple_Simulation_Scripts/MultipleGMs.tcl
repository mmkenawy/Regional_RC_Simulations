# Main Script to run several ground motion analyses using script runGMs.tcl which calls the lumped plasticity building moel LumpedModel.tcl
# This script is created based on script provided by Sashi Kunnath, UC Davis

source pathToGMs.tcl
#set GMdir "C:/GMfiles_FNsample"
#set dir "C:/S_11_81_FN"
#set dir "C:/S_11_17_FN"

puts "$GMdir"
set filename "simStatus.txt"
set fileid [open $filename "w"]
set GMcontents [glob -nocomplain -directory $GMdir *]
puts "$GMcontents"

set time_incr [open timeincr.txt]
set numPts [open numPts.txt]

source outputDir.tcl
file mkdir $dataDir
	
foreach item $GMcontents {
 set GMfile "$item" ;		# ground-motion filenames
 set GM [file tail $item];	
 set DtEQ [gets $time_incr];
 set Nsteps [gets $numPts];

puts $fileid $GM
set scalefact 1.0;
source runGMs.tcl
}
close $fileid
wipe;
