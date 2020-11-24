# ###########################################################################
#   Time History/Dynamic Analysis               			   			   #
# ###########################################################################
# get building name, data directory name and create the directory
source [pwd]/building_outputdir.tcl
#file mkdir $dataDir

# build the structural model
source [pwd]/LumpedModel.tcl

# open log file
set logfile [open "log$GM.txt" "w+"]
puts $logfile "Ground motion: $GM"

# ################################################################################### 
# # display deformed shape:
# set ViewScale 5;	# amplify display of deformed shape
# DisplayModel2D DeformedShape $ViewScale;	# display deformed shape, the scaling factor needs to be adjusted for each model
	
# element ranges for damping
set firstColumn [expr $N0col + 10 + 1];
set lastColumn	[expr $N0col + $Nstory*10 + $Nbay + 1];

#puts "firstColumn $firstColumn" 
#puts "lastColumn $lastColumn"

set firstBeam [expr $N0beam + 2*10 + 1];
set lastBeam [expr $N0beam + ($Nstory +1)*10 + $Nbay];

#puts "firstBeam $firstBeam" 
#puts "lastBeam $lastBeam"

# node ranges for damping
# only nodes with masses
set firstNode [expr 2*10 + 1]
set lastNode  [expr ($Nstory +1)*10 + $Nbay +1]

#puts "firstNode $firstNode" 
#puts "lastNode $lastNode"

# Rayleigh Damping
# calculate damping parameters
set nEigenI 1;		# mode 1
set nEigenJ 3;		
set lambda [eigen  [expr $nEigenJ]];			# eigenvalue analysis for nEigenJ modes
set T {}
set pi [expr 2.0*asin(1.0)];              			# Definition of pi
foreach lam $lambda {
lappend T [expr (2*$pi)/sqrt($lam)]
}
#puts "$T"
set lambdaI [lindex $lambda [expr $nEigenI-1]]; 		# eigenvalue mode i
set lambdaJ [lindex $lambda [expr $nEigenJ-1]]; 	# eigenvalue mode j
set wI [expr pow($lambdaI,0.5)];
set wJ [expr pow($lambdaJ,0.5)];

set n 10.0;
set zetaI 0.05;		# percentage of critical damping
set zetaJ 0.05;

set alpha [expr 2.0*$wI*$wJ*($wJ*$zetaI - $wI*$zetaJ)/(pow($wJ,2) - pow($wI,2))];	# mass damping coefficient based on first and second modes
set beta [expr 2.0*$wI*$wJ*(($zetaJ/$wI) - ($zetaI/$wJ))/(pow($wJ,2) - pow($wI,2))];			# stiffness damping coefficient based on first and second modes
set beta_mod [expr $beta*(1.0+$n)/$n];				# modified stiffness damping coefficient used for n modified elements. See Zareian & Medina 2010.
##puts "damping factors: $alpha $beta"

# damping factors based on first and second modes
# set zeta 0.02;
# set alpha [expr $zeta*2.0*$wI*$wJ/($wI + $wJ)];	# mass damping coefficient based on first and second modes
# set beta [expr $zeta*2.0/($wI + $wJ)];			# stiffness damping coefficient based on first and second modes

# assign damping to frame beams and columns		
# command: region $regionID -eleRange $elementIDfirst $elementIDlast -rayleigh $alpha_mass $alpha_currentStiff $alpha_initialStiff $alpha_committedStiff
region 11 -eleRange $firstColumn $lastColumn -rayleigh 0.0 0.0 $beta_mod 0.0;	# assign stiffness proportional damping to frame beams & columns w/ n modifications
region 22 -eleRange $firstBeam $lastBeam -rayleigh 0.0 0.0 $beta_mod 0.0;	# assign stiffness proportional damping to frame beams & columns w/ n modification
region 5 -nodeRange $firstNode $lastNode -rayleigh $alpha 0.0 0.0 0.0;		# assign mass proportional damping to structure (assign to nodes with mass)
	
# define ground motion parameters
set patternID 400;				# load pattern ID
set GMdirection 1;				# ground motion direction (1 = x)
set GMfact [expr $scalefact*$g];
	
# define the acceleration series for the ground motion
# syntax:  "Series -dt $timestep_of_record -filePath $filename_with_acc_history -factor $scale_record_by_this_amount
set accelSeries "Series -dt $DtEQ -filePath $GMfile -factor $GMfact";
	
# create load pattern: apply acceleration to all fixed nodes with UniformExcitation
pattern UniformExcitation $patternID $GMdirection -accel $accelSeries;
	
# record Interstory Drifts	
set outputfact [format {%2.2f} $scalefact]
	
for {set floor 1} {$floor <= [expr $Nstory]} {incr floor} {

set nodeI [expr $floor*10 + 1]; ##puts "$nodeI";
set nodeJ [expr ($floor + 1)*10 + 1]; ##puts "$nodeJ";
set floorName [format {%03d} $floor];

recorder Drift -file $dataDir/DriftFloor$outputfact$GM$floorName.out -iNode $nodeI  -jNode $nodeJ -dof 1 -perpDrin 2;
}
recorder Drift -file $dataDir/DrNode$outputfact$GM.out -iNode $SupportNodeFirst  -jNode $FreeNodeID  -dof 1 -perpDirn 2;	# lateral drift

# record base reactions
# for {set nodeID 1} {$nodeID <= [expr $Nbay+$PDparam]} {incr nodeID 1} {
# recorder Node -file RBaseSpr$nodeID$outputfact$GM.out -time -node [lindex $iSpringNode $nodeID-1] -dof 1 2 3 reaction;	# spring node reaction
# }


# define dynamic analysis parameters
	set dt_analysis 0.005;			# timestep of analysis
	set TmaxAnalysis [expr $Nsteps*$DtEQ];
	wipeAnalysis;					# destroy all components of the Analysis object, i.e. any objects created with system, numberer, constraints, integrator, algorithm, and analysis commands
	source [pwd]/LibAnalysisDynamicParameters.tcl;
	set NumASteps [expr int(($TmaxAnalysis + 0.0)/$dt_analysis)];	# number of steps in analysis
	
# perform the dynamic analysis and display whether analysis was successful	
set ok [analyze $NumASteps $dt_analysis];	# ok = 0 if analysis was completed
	
if {$ok != 0} {					# analysis was not successful.
# --------------------------------------------------------------------------------------------------
# change some analysis parameters to achieve convergence
# performance is slower inside this loop
#    Time-controlled analysis
set ok 0;
set controlTime [getTime];
while {$controlTime < $TmaxAnalysis && $ok == 0} {
	set controlTime [getTime]
	set ok [analyze 1 $dt_analysis]
	if {$ok != 0} {
		puts "Trying Broyden .."
		algorithm Broyden 8
		set ok [analyze 1 $dt_analysis]
		test $testTypeDynamic $TolDynamic $maxNumIterDynamic  0
		algorithm $algorithmTypeDynamic
	}
	if {$ok != 0} {
		puts "Trying Newton with Initial Tangent .."
		algorithm ModifiedNewton -initial
		set ok [analyze 1 $dt_analysis]
		algorithm $algorithmTypeDynamic
	}
	if {$ok != 0} {
		puts "Trying NewtonWithLineSearch .."
		algorithm NewtonLineSearch .8
		set ok [analyze 1 $dt_analysis]
		algorithm $algorithmTypeDynamic
	}
}
};      # end if ok !0

	if {$ok == 0} {
		puts $logfile "Dynamic analysis complete";
	} else {
		puts $logfile "Dynamic analysis did not converge";
	}		
	
# output time at end of analysis	
	set currentTime [getTime];	# get current analysis time	(after dynamic analysis)
	puts $logfile "Ground Motion Done. The current time is: $currentTime";
	close $logfile;
	wipe;