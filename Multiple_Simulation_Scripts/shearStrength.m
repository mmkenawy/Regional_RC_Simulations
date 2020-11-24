function Vn = shearStrength(f_c,fyh,b,h,d,s,Astx,Q)
%shearStrength: Compute nomibal shear strength of an RC section

%%%% input parameters
% f_c = compressive strength of concrete (MPa)
% fyh = yield strength of the transverse reinforcement (MPa)
% d = section depth (mm)
% s = spacing between hoops/stirrups (mm)
% Astx = area of steel transverse reinforcement in a single direction (number
% of reinforcement legs * the area of a single bar) (mm^2)

% units conversion
% the shear equation in ACI requires imperial units (here I am using lb, in
% and then converting back to N)
MPa = 145.038; %psi
lb = 4.4482; %N
N = 1/lb; %lb
in = 25.4; %mm
mm = 1/in; %in

% modification factor (depends on type of concrete)
lambda = 1.0; % for normal weight concrete

% Approximate ACI code equation 22.5.6.1 for shear strength contribution of
% concrete in members with axial compression
Vc = 2*(1 + Q*N/(2000*b*mm*h*mm))*lambda*min(sqrt(f_c*MPa),100)*b*mm*d*mm*lb; % in Newtons
% the axial load used in the equation should be the ultimate load on the
% column

% shear contribution from steel
Vs = Astx*fyh*d/s;

% Nominal shear strength
Vn = Vc + Vs;
end

