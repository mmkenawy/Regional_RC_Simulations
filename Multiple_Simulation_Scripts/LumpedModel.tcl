###################################################################################################
#          Set Up & Source Definition									  
###################################################################################################
	wipe all;							# clear memory of past model definitions
	model BasicBuilder -ndm 2 -ndf 3;	# Define the model builder, ndm = #dimension, ndf = #dofs
	#source DisplayModel2D.tcl;			# procedure for displaying a 2D perspective of model
	#source DisplayPlane.tcl;			# procedure for displaying a plane in a model
	source rotSpring2DModIKModel.tcl;	# procedure for defining a rotational spring (zero-length element)
	
 ###################################################################################################
 #          Define Building Geometry, Nodes, and Constraints											  
 ###################################################################################################
 # define structure-geometry parameters
	source frameInfo.tcl;
	# define units
	if {$units == 1} {
		source LibUnitsNmm.tcl;			  	# define units
		} elseif {$units == 2} {
			source LibUnits.tcl;}	
	
	set HBuilding [expr $Hcol1 + ($Nstory-1)*$Hcol2];	# height of building

# # define nodal coordinates
#puts "main nodes at beam-column intersecttions:";
	
for {set x 1} {$x <= [expr $Nbay +1] } {incr x} {

	set Xcoord [expr ($x- 1)*$Lbeam];
	for {set y 1} {$y <= [expr $Nstory +1] } {incr y} {
		set Ycoord [expr $Hcol1 + ($y - 2)*$Hcol2];
	if {$y < 2} {
		set Ycoord 0.;
		}
	set nodeID [expr $y*10+$x];
	
	node $nodeID $Xcoord $Ycoord;
	#puts "node $nodeID $Xcoord $Ycoord"
}}
	
# define extra nodes for plastic hinge rotational springs
	# nodeID convention:  "yxa" where x = Pier #, y = Floor #, a = location relative to beam-column joint
	# "a" convention: 2 = left; 3 = right;
	# "a" convention: 6 = below; 7 = above; 


	# nodes for column hinges
	#puts "extra nodes for column hinges:";	
	
	for {set x 1} {$x <= [expr $Nbay +1] } {incr x} {
	for {set y 1} {$y <= [expr $Nstory +1] } {incr y} {
	
	set Xcoord [expr ($x - 1)*$Lbeam];
	set Ycoord [expr $Hcol1 + ($y - 2)*$Hcol2];
	
	set a1 6;
	set a2 7;

	
	if {$y < 2} {
		set Ycoord 0.;
		set a1 7;
		} elseif {$y > $Nstory} {
		set a2 6;
		}
		
	if {$x < 2} {
		set Xcoord 0.;
		}
		
	for {set a $a1} { $a <= $a2 } {incr a} {
		node $y$x$a $Xcoord $Ycoord;
		#puts "$y$x$a $Xcoord $Ycoord"
		}
		
}}

	# nodes for beam hinges
	#puts "extra nodes for beam hinges:";
	
	for {set x 1} {$x < [expr $Nbay +2] } {incr x} {
	for {set y 2} {$y < [expr $Nstory +2] } {incr y} {

	
	set Xcoord [expr ($x - 1)*$Lbeam];
	set Ycoord [expr $Hcol1 + ($y - 2)*$Hcol2];
	
	set b1 2;
	set b2 3;

	
	if {$x < 2} {
		set Xcoord 0.;
		set b1 3;
		} elseif {$x > $Nbay} {
		set b2 2;
		}
		
	for {set b $b1} { $b <= $b2 } {incr b} {
		node $y$x$b $Xcoord $Ycoord
		#puts "$y$x$b $Xcoord $Ycoord"
		}
		
}}

# constrain beam-column joints in a floor to have the same lateral displacement using the "equalDOF" command
	# command: equalDOF $MasterNodeID $SlaveNodeID $dof1 $dof2...
	set dof1 1;	# constrain movement in dof 1 (x-direction)
	
	set x1 1;
	for {set y 2} {$y <= [expr $Nstory +1] } {incr y} {
	for {set x 2} {$x <= [expr $Nbay +1] } {incr x} {
	
	equalDOF $y$x1 $y$x $dof1;
	#puts "equalDOF $y$x1 $y$x $dof1";
}}

# assign boundary condidtions 
	# command:  fix nodeID dxFixity dyFixity rzFixity
	# fixity values: 1 = constrained; 0 = unconstrained
	# fix the base of the building; pin P-delta column at base
set y1 1;
for {set x 1} {$x < [expr $Nbay +2] } {incr x} {
	fix $y1$x 1 1 1;
	#puts "fix $y1$x 1 1 1";
	}
	
#puts "don't forget to add the p-delta column";


# ###################################################################################################
# #          Define Section Properties and Elements													  
# ###################################################################################################

source memParameters.tcl

# define ELEMENTS
# set up geometric transformations of element
#   separate columns and beams, in case of P-Delta analysis for columns
	set IDColTransf 1; # all columns
	set IDBeamTransf 2; # all beams
	set ColTransfType Corotational;			# options, Linear PDelta Corotational 
	geomTransf $ColTransfType $IDColTransf; 	# only columns can have PDelta effects (gravity effects)
	geomTransf Linear $IDBeamTransf
	
# define elastic column elements using "element" command
	# command: element elasticBeamColumn $eleID $iNode $jNode $A $E $I $transfID
	# eleID convention:  "111yx" where 111 = col, x = Pier #, y = Story #
	#puts "column elements:";
	set a1 6;
	set a2 7;
	set N0col 11100;
	for {set y 1} {$y <= $Nstory } {incr y} {
	
	#puts "floor $y";
	for {set x 1} {$x <= [expr $Nbay +1] } {incr x} {
	
	set memID [expr $N0col + $y*10 + $x];
	set nodeI [expr $y*100 + $x*10 + $a2];
	set nodeJ [expr ($y+1)*100 + $x*10 + $a1]
	
	
	element elasticBeamColumn  $memID $nodeI $nodeJ [set A_eleC$y$x] [set E_eleC$y$x] [set I_eleC$y$x] $IDColTransf;

	#puts "element elasticBeamColumn  $memID $nodeI $nodeJ [set A_eleC$y$x] [set E_eleC$y$x] [set I_eleC$y$x] $IDColTransf";
	##puts "element elasticBeamColumn  11$x$y  $x$y$a2 $x[expr $y+1]$a1 $Acol_12 $Es $Icol_12mod $IDColTransf"
}}

# define elastic beam elements using "element" command
	# command: element elasticBeamColumn $eleID $iNode $jNode $A $E $I $transfID
	# eleID convention:  "222xy" where 222 = beam, x = Pier #, y = Story #
	#puts "beam elements:";
	set b1 2;
	set b2 3;
	set N0beam 22200;
	for {set y 2} {$y <= [expr $Nstory +1] } {incr y} {
	
	#puts "level $y";
	set flr [expr $y - 1];
	for {set x 1} {$x <= $Nbay } {incr x} {
	
	set memID [expr $N0beam + $y*10 + $x];
	set nodeI [expr $y*100 + $x*10 + $b2];
	set nodeJ [expr $y*100 + ($x+1)*10 + $b1];
	
	
	element elasticBeamColumn  $memID  $nodeI $nodeJ [set A_eleB$flr] [set E_eleB$flr] [set I_eleB$flr] $IDBeamTransf;
	
	#puts "element elasticBeamColumn  $memID  $nodeI $nodeJ [set A_eleB$flr] [set E_eleB$flr] [set I_eleB$flr] $IDBeamTransf";
	##puts "element elasticBeamColumn  22$x$y  $x$y$b2 [expr $x +1]$y$b1 $Abeam_23 $Es $Ibeam_23mod $IDBeamTransf";
}}

 ###################################################################################################
 #          Define Rotational Springs for Plastic Hinges												  
 ###################################################################################################
 # define rotational spring properties and create spring elements using "rotSpring2DModIKModel" procedure
	# rotSpring2DModIKModel creates a uniaxial material spring with a bilinear response based on Modified Ibarra Krawinkler Deterioration Model
	# references provided in rotSpring2DModIKModel.tcl
	# input values that are constant for all springs
#	set LS 1000.0;			# basic strength deterioration (a very large # = no cyclic deterioration)
	set LK 0.0;			# unloading stiffness deterioration (a very large # = no cyclic deterioration)
	set LA 0.0;			# accelerated reloading stiffness deterioration (a very large # = no cyclic deterioration)
#	set LD 1000.0;			# post-capping strength deterioration (a very large # = no deterioration)
	set cS 1.0;				# exponent for basic strength deterioration (c = 1.0 for no deterioration)
	set cK 1.0;				# exponent for unloading stiffness deterioration (c = 1.0 for no deterioration)
	set cA 1.0;				# exponent for accelerated reloading stiffness deterioration (c = 1.0 for no deterioration)
	set cC 1.0;				# exponent for post-capping strength deterioration (c = 1.0 for no deterioration)
#	set th_pP 0.025;		# plastic rot capacity for pos loading
#	set th_pN 0.025;		# plastic rot capacity for neg loading
#	set th_pcP 0.3;			# post-capping rot capacity for pos loading
#	set th_pcN 0.3;			# post-capping rot capacity for neg loading
	# set ResP 0.01;			# residual strength ratio for pos loading
	# set ResN 0.01;			# residual strength ratio for neg loading
#	set th_uP 0.4;			# ultimate rot capacity for pos loading
#	set th_uN 0.4;			# ultimate rot capacity for neg loading
	set DP 1.0;				# rate of cyclic deterioration for pos loading
	set DN 1.0;				# rate of cyclic deterioration for neg loading

# define column springs
	# Spring ID: "3yxa", where 3 = col spring, x = Pier #, y = Story #, c = location in story
	# "a" convention: 1 = bottom of story, 2 = top of story
	# command: rotSpring2DModIKModel	id    ndR  ndC     K   asPos  asNeg  MyPos      MyNeg      LS    LK    LA    LD   cS   cK   cA   cD  th_p+   th_p-   th_pc+   th_pc-  Res+   Res-   th_u+   th_u-    D+     D-
	set c1 1;
	set c2 2;
	set a1 6;
	set a2 7;
	set colSprings ""
	#puts "Column springs:";
	for {set y 1} {$y <= $Nstory } {incr y} {
	#puts "floor $y";
	for {set x 1} {$x <= [expr $Nbay +1] } {incr x} {
	
	rotSpring2DModIKModel 3$y$x$c1 $y$x $y$x$a2 [set K_sprC$y$x] [set a_sprC$y$x] [set a_sprC$y$x] [set My_spr_posC$y$x] [expr -[set My_spr_posC$y$x]] \
	[set Lambda_SC$y$x] [set Lambda_CC$y$x] $LA $LK $cS $cC $cA $cK [set theta_p_sprC$y$x] [set theta_p_sprC$y$x] [set theta_pc_sprC$y$x] \
	[set theta_pc_sprC$y$x] $ResP $ResN [set theta_u_sprC$y$x] [set theta_u_sprC$y$x] $DP $DN;
	rotSpring2DModIKModel 3$y$x$c2 [expr $y+1]$x [expr $y+1]$x$a1 [set K_sprC$y$x] [set a_sprC$y$x] [set a_sprC$y$x] [set My_spr_posC$y$x] [expr -[set My_spr_posC$y$x]] \
	[set Lambda_SC$y$x] [set Lambda_CC$y$x] $LA $LK $cS $cC $cA $cK [set theta_p_sprC$y$x] [set theta_p_sprC$y$x] [set theta_pc_sprC$y$x] \
	[set theta_pc_sprC$y$x] $ResP $ResN [set theta_u_sprC$y$x] [set theta_u_sprC$y$x] $DP $DN;
	
	
	#puts "rotSpring2DModIKModel 3$y$x$c1 $y$x $y$x$a2 [set K_sprC$y$x] [set a_sprC$y$x] [set a_sprC$y$x] [set My_spr_posC$y$x] [expr -[set My_spr_posC$y$x]] \
	[set Lambda_SC$y$x] [set Lambda_CC$y$x] $LA $LK $cS $cC $cA $cK [set theta_p_sprC$y$x] [set theta_p_sprC$y$x] [set theta_pc_sprC$y$x] \
	[set theta_pc_sprC$y$x] $ResP $ResN [set theta_u_sprC$y$x] [set theta_u_sprC$y$x] $DP $DN;"
	#puts "rotSpring2DModIKModel 3$y$x$c2 [expr $y+1]$x [expr $y+1]$x$a1 [set K_sprC$y$x] [set a_sprC$y$x] [set a_sprC$y$x] [set My_spr_posC$y$x] [expr -[set My_spr_posC$y$x]] \
	[set Lambda_SC$y$x] [set Lambda_CC$y$x] $LA $LK $cS $cC $cA $cK [set theta_p_sprC$y$x] [set theta_p_sprC$y$x] [set theta_pc_sprC$y$x] \
	[set theta_pc_sprC$y$x] $ResP $ResN [set theta_u_sprC$y$x] [set theta_u_sprC$y$x] $DP $DN;"
	
	lappend colSprings 3$y$x$c1;
	lappend colSprings 3$y$x$c2;
	}}
	
	
# define beam springs
	# Spring ID: "4yxa", where 4 = beam spring, x = Bay #, y = Floor #, c = location in bay
	# "c" convention: 1 = left end, 2 = right end

	set c1 1;
	set c2 2;
	set b1 2;
	set b2 3;
	set beamSprings ""
	#puts "beam springs:";
	for {set y 2} {$y <= [expr $Nstory +1] } {incr y} {
	#puts "level $y";
	for {set x 1} {$x <= $Nbay } {incr x} {
	
	set flr [expr $y - 1];
	
	rotSpring2DModIKModel 4$y$x$c1 $y$x $y$x$b2 [set K_sprB$flr] [set a_sprB$flr] [set a_sprB$flr] [set My_spr_posB$flr] \
	[expr -[set My_spr_posB$flr]] [set Lambda_SB$flr] [set Lambda_CB$flr] $LA $LK  $cS $cC $cA $cK  [set theta_p_sprB$flr] \
	[set theta_p_sprB$flr] [set theta_pc_sprB$flr] [set theta_pc_sprB$flr] $ResP $ResN [set theta_u_sprB$flr] [set theta_u_sprB$flr] $DP $DN;
	rotSpring2DModIKModel 4$y$x$c2 $y[expr $x +1] $y[expr $x +1]$b1 [set K_sprB$flr] [set a_sprB$flr] [set a_sprB$flr] [set My_spr_posB$flr] \
	[expr -[set My_spr_posB$flr]] [set Lambda_SB$flr] [set Lambda_CB$flr] $LA $LK  $cS $cC $cA $cK  [set theta_p_sprB$flr] \
	[set theta_p_sprB$flr] [set theta_pc_sprB$flr] [set theta_pc_sprB$flr] $ResP $ResN [set theta_u_sprB$flr] [set theta_u_sprB$flr] $DP $DN;

	#puts "rotSpring2DModIKModel 4$y$x$c1 $y$x $y$x$b2 [set K_sprB$flr] [set a_sprB$flr] [set a_sprB$flr] [set My_spr_posB$flr] \
	[expr -[set My_spr_posB$flr]] [set Lambda_SB$flr] [set Lambda_CB$flr] $LA $LK  $cS $cC $cA $cK  [set theta_p_sprB$flr] \
	[set theta_p_sprB$flr] [set theta_pc_sprB$flr] [set theta_pc_sprB$flr] $ResP $ResN [set theta_u_sprB$flr] [set theta_u_sprB$flr] $DP $DN;"
	#puts "rotSpring2DModIKModel 4$y$x$c2 $y[expr $x +1] $y[expr $x +1]$b1 [set K_sprB$flr] [set a_sprB$flr] [set a_sprB$flr] [set My_spr_posB$flr] \
	[expr -[set My_spr_posB$flr]] [set Lambda_SB$flr] [set Lambda_CB$flr] $LA $LK  $cS $cC $cA $cK  [set theta_p_sprB$flr] \
	[set theta_p_sprB$flr] [set theta_pc_sprB$flr] [set theta_pc_sprB$flr] $ResP $ResN [set theta_u_sprB$flr] [set theta_u_sprB$flr] $DP $DN;"
	
	lappend beamSprings 4$y$x$c1;
	lappend beamSprings 4$y$x$c2;
	}}

#DisplayModel2D NodeNumbers

 ############################################################################
 #              Gravity Loads & Gravity Analysis
 ############################################################################

# assign masses to the nodes that the columns are connected to 
# each connection takes the mass of 1/2 of each element framing into it (mass=weight/$g)
set iFloorWeight ""
set WeightTotal 0.0
set sumWiHi 0.0;		# sum of storey weight times height, for lateral-load distribution
#puts "Nodal masses:";
for {set level 2} {$level <=[expr $Nstory+1]} {incr level 1} { ;
set flr [expr $level - 1]
#puts "floor $flr";
		
for {set pier 1} {$pier <= [expr $Nbay+1]} {incr pier 1} {;
	
		set MassNode [set nodalMass$level$pier];
		set nodeID [expr $level*10+$pier]
		mass $nodeID $MassNode $Usmall $Usmall;			# define mass
		#puts "mass $nodeID $MassNode $Usmall $Usmall";
	}
	set FloorWeight [set floorWeight$flr];
	lappend iFloorWeight $FloorWeight;
	set WeightTotal [expr $WeightTotal+ $FloorWeight];

	set sumWiHi [expr $sumWiHi+$FloorWeight*(($level-2)*$Hcol2 + $Hcol1)];		# sum of storey weight times height, for lateral-load distribution
}
	#set MassTotal [expr $WeightTotal/$g];						# total mass

# add the PDelta column if needed
if {$PDeltaCol == 1} {
	source PDeltaCol.tcl;}

# determine support nodes
#puts "Support nodes:";
set iBaseNode ""
set iSpringNode ""
set level 1

if {$PDeltaCol == 1} {
	set PDparam 2;
	} else {
	set PDparam 1;}
	
for {set pier 1} {$pier <= [expr $Nbay+$PDparam]} {incr pier 1} {
	set baseNodeID [expr int($level*10 + $pier)]
	lappend iBaseNode $baseNodeID
	
	if {$pier == $Nbay + 2} {
		set springNodeID [expr int($level*10 + $pier)]
		} else {
			set springNodeID [expr int($level*100 + $pier*10 + 7)]
			}
	lappend iSpringNode $springNodeID
	
	#puts "Support node ID $baseNodeID";
	#puts "Reaction node ID $springNodeID";
}
	

# define GRAVITY -------------------------------------------------------------
# GRAVITY LOADS # define gravity load applied to beams and columns -- eleLoad applies loads in local coordinate axis
pattern Plain 101 Linear {
	for {set y 1} {$y <=$Nstory} {incr y 1} {
	#puts "Loads on columns of story $y";
		for {set x 1} {$x <= [expr $Nbay+1]} {incr x 1} {
			set memID [expr $N0col + $y*10 + $x];
			eleLoad -ele $memID -type -beamUniform 0 [expr -[set colUniform$y]]; 	# COLUMNS
			#puts "eleLoad -ele $memID -type -beamUniform 0 [expr -[set colUniform$y]]";
		}
	}
	for {set y 2} {$y <=[expr $Nstory+1]} {incr y 1} {
	#puts "Loads on beams of level $y";
		for {set x 1} {$x <= $Nbay} {incr x 1} {
			set memID [expr $N0beam + $y*10 + $x];
			set flr [expr $y - 1];
			eleLoad -ele $memID  -type -beamUniform [expr -[set beamUniform$flr]]; 	# BEAMS
			#puts "eleLoad -ele $memID  -type -beamUniform [expr -[set beamUniform$flr]]";
		}
	}
}

# # Gravity-analysis parameters -- load-controlled static analysis

# Set up parameters that are particular to the model for displacement control
set IDctrlNode [expr ($Nstory+1)*10 + 1];		# node where displacement is read for displacement control
#puts "IDctrlNode $IDctrlNode";
set IDctrlDOF 1;		# degree of freedom of displacement read for displacement control
	
	
	set Tol 1.0e-3;			# convergence tolerance for test
	variable constraintsTypeGravity Plain;		# default;
	# if {  [info exists RigidDiaphragm] == 1} {
		# if {$RigidDiaphragm=="ON"} {
		# variable constraintsTypeGravity Lagrange;	#  large model: try Transformation
	# };	# if rigid diaphragm is on
# };	# if rigid diaphragm exists
	constraints $constraintsTypeGravity ;     		# how it handles boundary conditions
	numberer RCM;			# renumber dof's to minimize band-width (optimization), if you want to
	system BandGeneral ;		# how to store and solve the system of equations in the analysis (large model: try UmfPack)
	test NormUnbalance $Tol 100; 		# determine if convergence has been achieved at the end of an iteration step
	algorithm Newton;			# use Newton's solution algorithm: updates tangent stiffness at every iteration
	set NstepGravity 10;  		# apply gravity in 10 steps
	set DGravity [expr 1./$NstepGravity]; 	# first load increment;
	integrator LoadControl $DGravity;	# determine the next time step for an analysis
	analysis Static;			# define type of analysis static or transient
	analyze $NstepGravity;		# apply gravity

# ------------------------------------------------- maintain constant gravity loads and reset time to zero	
	loadConst -time 0.0
	#puts "Model Built"
	
# # Define RECORDERS -------------------------------------------------------------
set FreeNodeID [expr ($Nstory+1)*10 + 1];					# ID: free node
# #puts "FreeNodeID $FreeNodeID";
set SupportNodeFirst [lindex $iBaseNode 0];						# ID: first support node
set SupportNodeLast [lindex $iBaseNode [expr [llength $iBaseNode]-1]];			# ID: last support node
# #puts "$SupportNodeFirst $SupportNodeLast";
set FirstColumn [expr $N0col+11];							# ID: first column


# if running a single simulations with tradtitional output (total building drift and base reactions )
if {$analysisType == "dynamic" || $analysisType == "freevib" || $analysisType == "pushover" || \
$analysisType == "dynamicpushover" || $analysisType == "cyclic"} {
	recorder Node -file DFree.out -time -node $FreeNodeID  -dof 1 2 3 disp;				# displacements of free node
	for {set nodeID 1} {$nodeID <= [expr $Nbay+$PDparam]} {incr nodeID 1} {
	recorder Node -file DBaseNode$nodeID.out -time -node [lindex $iBaseNode $nodeID-1] -dof 1 2 3 disp;	# displacements of support nodes
	recorder Node -file RBaseNode$nodeID.out -time -node [lindex $iBaseNode $nodeID-1] -dof 1 2 3 reaction;	# support reaction
	recorder Node -file DBaseSpr$nodeID.out -time -node [lindex $iSpringNode $nodeID-1] -dof 1 2 3 disp;	# displacements of spring nodes
	recorder Node -file RBaseSpr$nodeID.out -time -node [lindex $iSpringNode $nodeID-1] -dof 1 2 3 reaction;	# spring node reaction
	}
	recorder Drift -file DrNode.out -time -iNode $SupportNodeFirst  -jNode $FreeNodeID  -dof 1 -perpDirn 2;	# lateral drift
	
	# if running a ground motion simulation with detailed output (inter-story drifts and moment-rotation of joints)
	} elseif {$analysisType == "detailedGMs"} {
	# record the displacement at each floor
for {set y 1} {$y <= [expr $Nstory+1]} {incr y 1} {
	set Node [expr $y*10 + 1];
	set Nodeout [format {%3.3d} $Node]
	recorder Node -file $dataDir/Disp$Nodeout.out -time -node $Node  -dof 1 2 3 disp
	}

# record response history of all frame column springs (one file for moment, one for rotation)
	set c1 1;
	set c2 2;
for {set y 1} {$y <= $Nstory } {incr y} {
	#puts "floor $y";
	for {set x 1} {$x <= [expr $Nbay +1] } {incr x} {
	
	set yout [format {%2.2d} $y]
	set xout [format {%2.2d} $x]
	
	recorder Element -file $dataDir/ColSprMoment3$yout$xout$c1.out -ele 3$y$x$c1 force;
	recorder Element -file $dataDir/ColSprRot3$yout$xout$c1.out -ele 3$y$x$c1 deformation;
	
	recorder Element -file $dataDir/ColSprMoment3$yout$xout$c2.out -ele 3$y$x$c2 force;
	recorder Element -file $dataDir/ColSprRot3$yout$xout$c2.out -ele 3$y$x$c2 deformation;
	}}
	
	set c1 1;
	set c2 2;
	for {set y 2} {$y <= [expr $Nstory +1] } {incr y} {
	#puts "level $y";
	for {set x 1} {$x <= $Nbay } {incr x} {
	
	set flr [expr $y - 1];
	set yout [format {%2.2d} $y]
	set xout [format {%2.2d} $x]
	recorder Element -file $dataDir/BeamSprMoment4$yout$xout$c1.out -ele 4$y$x$c1 force;
	recorder Element -file $dataDir/BeamSprRot4$yout$xout$c1.out -ele 4$y$x$c1 deformation;
	
	recorder Element -file $dataDir/BeamSprMoment4$yout$xout$c2.out -ele 4$y$x$c2 force;
	recorder Element -file $dataDir/BeamSprRot4$yout$xout$c2.out -ele 4$y$x$c2 deformation;
	}}
	}
	
	# ############################################################################
	# #                       Eigenvalue Analysis                    			   
	# ############################################################################
	# set pi [expr 2.0*asin(1.0)];						# Definition of pi
	# set nEigenI 1;										# mode i = 1
	# set nEigenJ 3;										# mode j = 3
	# set lambdaN [eigen [expr $nEigenJ]];				# eigenvalue analysis for nEigenJ modes
	# set lambdaI [lindex $lambdaN [expr 0]];				# eigenvalue mode i = 1
	# set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];	# eigenvalue mode j = 2
	# set wI [expr pow($lambdaI,0.5)];					# w1 (1st mode circular frequency)
	# set wJ [expr pow($lambdaJ,0.5)];					# w2 (2nd mode circular frequency)
	# set TI [expr 2.0*$pi/$wI];							# 1st mode period of the structure
	# set TJ [expr 2.0*$pi/$wJ];							# 2nd mode period of the structure
	# puts " T$nEigenI = $TI s";									# display the first mode period in the command window
	# puts "T$nEigenJ = $TJ s";									# display the second mode period in the command window
	
	if {$analysisType == "dynamic"} {
		source dynamic.tcl
		} elseif {$analysisType == "freevib"} {
			source FreeVib.tcl
		} elseif {$analysisType == "pushover"} {
			source pushover.tcl
			} elseif {$analysisType == "dynamicpushover"} {
				source dynamicpushover.tcl
				} elseif {$analysisType == "cyclic"} {
				source cyclic.tcl}