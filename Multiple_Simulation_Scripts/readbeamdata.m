function [ f_c,e_co,e_zero_ucc,Ec,fyl,bst_tangent,Est,fyh,b,h,topccover,btmccover,...
    phi_tr,legs,s,sclear,Abar_tr,phi_top,phi_btm,phi_l,rho_top,rho_btm,ntop,nbtm,...
    ntotal,Abar_top,Abar_btm,nxtop,nxbtm,wi,As_top,As_btm,Astotal,dc,bc,rho_l_core,L,...
    Q,steellayer_top,steellayer_btm,rho_tr_area,config,eta,Astx,...
    As_vec,d_vec,d,rho_vec,dFardis] = readbeamdata(beam,inputunits)

% read input data
data = xlsread(beam,'C1:C22');

% general parameters
%%% unconfined concrete parameters
f_c = data(1);
e_co = data(2);
e_zero_ucc = data(3);
if inputunits == 1
    Ec = 4700*sqrt(f_c);
elseif inputunits == 2
    Ec = 57*sqrt(f_c*1000);
end

% Steel material parameters
% long. steel
fyl = data(4);
bst_tangent = data(5);
Est = data(6);
% transverse steel
fyh = data(7);

% section geomerty and reinforcement
b = data(8); % square section
h = data(9);
topccover = data(10);
btmccover = data(11);

% transverse reinforcement
phi_tr = data(12);
legs = data(13);
s = data(14);
sclear = s - phi_tr;
Abar_tr = pi*phi_tr^2/4;

% longitudinal reinforcement
phi_top = data(15);
phi_btm = data(16);
phi_l = phi_top; % in cases where you need a single longitudinal diameter, just
% use phi_top
ntop = data(17);
nbtm = data(18);
ntotal = ntop + nbtm;

Abar_top = pi*phi_top^2/4;
Abar_btm = pi*phi_btm^2/4;

nxtop = data(19); %number of top longitudinal bars in a single row (used to determine clear spacing
% between longitudinal bars, which may be used to determine confinement in
% future models
nxbtm = data(20);
witop = (h - (topccover*2)-(legs*phi_tr)-(nxtop*phi_top))/(nxtop-1); % clear long. bar spacing - top rft
wibtm = (h - (btmccover*2)-(legs*phi_tr)-(nxbtm*phi_btm))/(nxbtm-1); % clear long. bar spacing - btm rft
wi = max(witop,wibtm);

As_top = ntop*Abar_top;
As_btm = nbtm*Abar_btm;
Astotal = As_top + As_btm;

% column length
L = data(21);

% imposed axial load
Q = 0.0; % for now
eta = Q/(f_c*b*h);

config = data(22); % for now config 8 is the only beam config. It means beam with nonuniform
% top and bottom rft
    
%%% calculate some geometric parameters
[As_vec,d_vec,dFardis,rho_vec] = beamRftGeometry(Abar_top,Abar_btm,config,phi_top,...
    phi_btm,ntop,nbtm,nxtop,nxbtm,phi_tr,topccover,btmccover,b,h);
%cover to long. steel NA
steellayer_top = topccover + phi_tr + 0.5*phi_top;
steellayer_btm = btmccover + phi_tr + 0.5*phi_btm;
% core dimensions
dc = h - topccover - btmccover - phi_tr;
bc = b - topccover - btmccover - phi_tr;

rho_l_core = Astotal/(bc*dc); % ratio of long. reinf. to core area

%%%% longitudinal reinforcement ratios
d = d_vec(end); %effective depth of the section
rho_top = As_top/(b*d);
rho_btm = As_btm/(b*d);

% for now config 8 is the only beam config. It means beam with nonuniform
% top and bottom rft
Astx = legs*Abar_tr; % total area of transverse reinf in one direction

%rho_x = Astx/(dc*s);  % area ratio of transverse reinforcement to core per direction
rho_tr_area = Astx/(b*s); % total area ratio of transverse reinf
%%%%%%%%%%%%% note: change dc to b for consistency with Haselton

end

