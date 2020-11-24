function [A_ele,E_ele,I_ele,I_mem,K_spr,a_spr,My_spr_pos,Lambda_S,Lambda_C,...
    theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = IMKCalibration(memName,L,axialLoad,inputunits)
%%% June 10, 2019
%%% Script to use RC beam-column properties to calibrate the parameters of
%%% the lumped plasticity IMK model
%%% The calibration equations are based on the PEER 2007/03 Report by
%%% Haselton et al.
%%% July 30, 2019: The calibration is now based on a modified version of
%%% the equations in Haselton et al. 2016 (ACI paper)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input Beam-Column Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (either from the excel file or directly as input here)

load(memName,'f_c','Ec','fyl','Est','fyh','b','h','s','phi_l',...
    'rho_tr_area','Astx','As_vec','d_vec','d','rho_vec','dFardis');

Q = axialLoad;
eta = Q/(f_c*b*h);
BC = 'double'; % cantilever or double (means in double curvature)

% bond-slip indicator (= 0 if bond-slip is not possible; = 1 if bond-slip is possible. use as zero for now)
asl = 1.0;

% units conversion coefficient (= 1.0 for MPa; = 6.9 for Ksi)
if inputunits == 1
    cunits = 1.0;
elseif inputunits == 2
    cunits = 6.9;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Computed Beam-Column Parameters (based on input parameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. gross flexural rigidity of the section
I_sec = b*h^3/12;
EIg = Ec*b*h^3/12;

% 2. shear span to depth ratio
LoverH = L/h;

% 3. rebar buckling coefficient
Sn = (s/phi_l)*(cunits*fyl/100)^0.5;

% 4. effective confinement ratio
rho_sh = rho_tr_area;
rho_sh_eff = rho_sh*fyh/f_c;

% 5. Nominal Shear strength Vn
Vn = shearStrength(f_c,fyh,b,h,d,s,Astx,Q);

% 6. Flexural strength My
% use expected material parameters
f_c_exp = 1.25*f_c;
fyl_exp = 1.2*fyl;
My = flexuralStrength(f_c_exp,fyl_exp,b,h,Est,Q,As_vec,d_vec,d);

% 7. Flexural strength and deformation at yield using the approximate method in Panagiotakos and
% Fardis (2001)
%[My,theta_y,phi_y] = MyApprox(f_c,fyl,b,dFardis,phi_l,Est,Ec,Q,L,asl,d_vec,d,As_vec);

% 8. Reinforcement ratios
%get the rft geometry info
rhoc = rho_vec(1);
rhot = rho_vec(3);
rho_tot = sum(rho_vec(1:3));
%rho_tot = sum(As_vec(:))/(b*h);

% 9. transverse reinforcement spacing over logitudinal bar diameter (S/D)
SoverD = s/d;

% 9. BC coefficients
iscantilever = strcmp(BC,'cantilever');
isdouble = strcmp(BC,'double');
if iscantilever == 1
BCfac = 3.0;
L_inf = L;
elseif isdouble == 1
    BCfac = 6.0;
    L_inf = L/2;
else
    disp('enter a valid BC: either cantilever or double')
end

% 10. ratio of shear demand at flexural yielding to shear strength of the
% column

Vp = My/L_inf;
VpoverVn = Vp/Vn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calibrated Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Initial stiffness EIy or Ke (secant stiffness to yield point)
%EIy_EIg = -0.07 + 0.59*eta + 0.07*LoverH;

% %simplified egn
%EIy_EIg = 0.065 + 1.05*eta;

% Initial stiffness equation from the ACI 2016 paper
EIy_EIg = 0.3*power(0.1 + eta,0.8)*power(LoverH,0.72);

if EIy_EIg < 0.2
    EIy_EIg = 0.2;
end

if EIy_EIg > 0.6
    EIy_EIg = 0.6;
end

EIy = EIy_EIg*EIg;
%EIy = EIg;


% 2. Initial stiffness EI40 or K40 (secant stiffness to 40% of yield)
%EI40_EIg = -0.02 + 0.98*eta + 0.09*LoverH;

% % simplfied eqn
%EI40_EIg = 0.17 + 1.61*eta;

% initial stiffness equation from the ACI 2016 paper
EI40_EIg = 0.77*power(0.1 + eta,0.8)*power(LoverH,0.43);

if EI40_EIg < 0.35
    EI40_EIg = 0.35;
end

if EI40_EIg > 0.8
    EI40_EIg = 0.8;
end

EI40 = EI40_EIg*EIg;
EIy = EI40;
% 3. Plastic rotation capacity theta_pl

%coefficient to account for unbalanced reinforcement in beams
unbal = max(0.01,rhoc*fyl/f_c)/max(0.01,rhot*fyl/f_c); %there is a mistake in the Haselton equation
% the effect of unbalanced reinforcement is accounted for differently in
% the PEER-ATC-72 report (the power is dropped from the following equations)

% plastic roration capacity
theta_pl = 0.12 * power(unbal,0.225) * (1 + 0.55*asl) * power(0.16,eta) * power(0.02 + 40*rho_sh,0.43)...
    * power(0.54,0.01*cunits*f_c) * power(0.66,0.1*Sn)*power(2.27,10*rho_tot);

% %simplified eqn
% theta_pl = 0.13 * power(unbal,0.225) * (1 + 0.55*asl) * power(0.13,eta) * power(0.02 + 40*rho_sh,0.65)...
%     * power(0.57,0.01*cunits*f_c);

% 4. Total rotation capacity (theta_tot)
% theta_tot = 0.14 * power(unbal,0.175) * (1 + 0.4*asl) * power(0.19,eta) * power(0.02 + 40*rho_sh,0.54)...
%     * power(0.62,0.01*cunits*f_c);

% another equation
% theta_tot = 0.12 * power(unbal,0.175) * (1 + 0.4*asl) * power(0.2,eta) * power(0.02 + 40*rho_sh,0.52)...
%     * power(0.56,0.01*cunits*f_c) * power(2.37,10*rho_tot);



% 5. Post-capping rotation capacity theta_pc
theta_pc = 0.76 * 0.031^eta * (0.02 + 40*rho_sh)^1.02;

if theta_pc > 0.1
    theta_pc = 0.1;
end

% 6. Post-yield hardening stiffness (Mc/My)
%McoverMy = 1.25 * 0.89^eta * 0.91^(0.01*cunits*f_c);
McoverMy = 1.13;

% 7. cyclic strength and stiffness deterioration lambda
% lambda = 127.2 * power(0.19,eta) * power(0.24,s/d) * power(0.595,VpoverVn)...
%     * power(4.25,rho_sh_eff); % from the old 2008 Haselton report

%cyclic deterioration using the equation in the 2016 paper
lambda = 30*0.3^eta; %(to be multiplied by theta_pl)
% has more prediction dispersion than the following gamma equation, but is more
% appealing because the dissipation capacity is highly correlated with the plastic
% rotation capacity

% cyclic deterioration using the equation in the 2016 ACI paper
gamma = 170.7 * power(0.27,eta) * power(0.1,SoverD); %(to be multiplied by theta_y)

% 8. Deterioration exponent c_det
c_det = 1.0;

% 9. Residual Strength res
res = 0.1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input for OpenSees
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% each member is modeled as an elastic beam-column element and nonlinear
% springs at the element ends (using zero-length elements and uniaxial
% bilin material)

%0. Area
A_ele = b*h;

% 1. stiffness
% apply stiffness modifications to get the correct combined member
% stiffness
n = 10.0;

% assume
E_mem = Ec;
I_mem = EIy/E_mem;

% 1.1. for the elastic beam column element
E_ele = E_mem;
I_ele = (n+1)/n*I_mem;

% 1.2. for the spring
% for members in double-curvature

Ke_mem = BCfac*EIy/L;
Ke_ele = BCfac*E_ele*I_ele/L;
Ke_ele_check = (n+1)/n*Ke_mem;

K_spr = n*Ke_ele;

K_spr_check = (n+1)*Ke_mem;


% post-computations
%theta_y = theta_tot - theta_pl;
%My = Ke_mem*theta_y;
theta_y = My/Ke_mem;

% 2. strain-hardening ratio
% hardening stiffness Ks
Ks_mem = Ke_mem*theta_y/theta_pl*(McoverMy - 1);
a_mem = Ks_mem/Ke_mem;

if a_mem < 0.0
    a_mem = 0.00001;
end

%a_mem = My*(McoverMy - 1)/((K_spr/n)*theta_pl); % Lignos Equation
% gives similar results but not identical (some discrepancy with the n
% scaling)

a_spr = a_mem/(1 + n*(1 - a_mem));

% find Ks_spr given than the element and spring are in series
% Ks_spr = Ks_mem*Ke_ele/(Ke_ele - Ks_mem);
% a_spr = Ks_spr/K_spr; % it turns out this is the same as the previous one

% post-capping stiffness Kc
Kc_mem = -Ke_mem*theta_y/theta_pc*McoverMy;
ac_mem = Kc_mem/Ke_mem;

% Kc_spr = Kc_mem*Ke_ele/(Ke_ele - Kc_mem);
% alpha_c = Kc_spr/K_spr;

% 3. yield moment
My_spr_pos = My;
My_spr_neg = -My;

% 4. cyclic strength deterioration parameters
Lambda_S = lambda*theta_pl; % basic strength deterioration parameter
%Lambda_S = gamma*theta_y; % basic strength deterioration parameter (ACI 2016 paper)
%[E_t=Lamda_S*M_y; set Lamda_S = 0 to disable this mode of deterioration]
Lambda_C	= Lambda_S; %Cyclic deterioration parameter for post-capping strength deterioration
%[E_t=Lamda_C*M_y; set Lamda_C = 0 to disable this mode of deterioration]
Lambda_A	= 0.0; %Cyclic deterioration parameter for acceleration reloading stiffness deterioration
%(is not a deterioration mode for a component with Bilinear hysteretic response)
%[Input value is required, but not used; set Lamda_A = 0].
Lambda_K	= 0.0; %Cyclic deterioration parameter for unloading stiffness deterioration
%[E_t=Lamda_K*M_y; set Lamda_k = 0 to disable this mode of deterioration

% 5. Deterioration exponents
C_S = 1.0;
C_C = 1.0;
C_A = 1.0;
C_K = 1.0;

% 6. Plastic Rotation Capacity
theta_p_spr = theta_pl;

% derive the correct plastic rotation capacity of the spring
%theta_p_spr = theta_pl*(1 - n*a_mem/((1+a_mem)*(n+1))); % gives more accurate results
%%%%%%%% however, it was not mentioned anywhere in the literature
% it changes the value of Mc a little to maintain the same hardening ratio

% 7.Post capping rotation capacity
theta_pc_spr = theta_pc;

% derive the correct post-capping rotation capacity of the spring
%theta_pc_spr = theta_pc*(1 + n*a_mem/((1 + a_mem + a_mem/ac_mem)*(n+1))); % gives more accurate results
%%%%%%%% however, it was not mentioned anywhere in the literature

% 8. Residual Stength ratio
Res_spr = res;

% 9. ultimate rotation capacity
theta_u_spr = 2*(theta_y + theta_pl + theta_pc); % a large number to avoid convergence issues
%because this value does not matter

% 10. Rate of cyclic deterioration
D_spr = 1.0; % for symmetric hysteretic response;
end