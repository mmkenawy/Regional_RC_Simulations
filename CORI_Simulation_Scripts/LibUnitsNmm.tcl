# --------------------------------------------------------------------------------------------------
# LibUnits.tcl -- define system of units
#		Silvia Mazzoni & Frank McKenna, 2006
#

# define UNITS ----------------------------------------------------------------------------
set mm 1.; 				# define basic units -- output units
set N 1.;				# define basic units -- output units
set sec 1.; 			# define basic units -- output units
set LunitTXT "mm";			# define basic-unit text for output
set FunitTXT "N";			# define basic-unit text for output
set TunitTXT "sec";			# define basic-unit text for output
set kN 1000*$N;
set in [expr 25.4*$mm]; 				# define basic units -- output units
set lbf [expr 4.4482*$N]; 			# define basic units -- output units
set kips [expr 1000*$lbf]
set ft [expr 12.*$in]; 		# define engineering units
set ksi [expr $kips/pow($in,2)];
set psi [expr $ksi/1000.];
set pcf [expr $lbf/pow($ft,3)];		# pounds per cubic foot
set psf [expr $lbf/pow($ft,2)];		# pounds per square foot
set in2 [expr $in*$in]; 		# inch^2
set in4 [expr $in*$in*$in*$in]; 		# inch^4
set cm [expr 10*$mm];		# centimeter, needed for displacement input in MultipleSupport excitation
set m [expr 1000*$mm]
set PI [expr 2*asin(1.0)]; 		# define constants
#set g [expr 9.81*$m/pow($sec,2)]; 	# gravitational acceleration
set Ubig 1.e9; 			# a really large number
set Usmall 1.e-9; 		# a really small number
