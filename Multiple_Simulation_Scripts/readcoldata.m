function [ f_c,e_co,e_zero_ucc,Ec,fyl,bst_tangent,ful,Est,fyh,b,h,ccover,phi_tr,...
    rho_tr,legs,s,sclear,Abar_t,phi_l,rho_l,nx,ntotal,Abar_l,...
    wi,As,dc,bc,rho_l_core,L,cover,Q,steellayer,rho_tr_area,config,eta,Astx,...
    As_vec,d_vec,d,rho_vec,dFardis] = readcoldata(column,inputunits)

% read input data
data = xlsread(column,'C1:C22');

% general parameters
%%% unconfined concrete parameters
f_c = data(1);
%f_c = 1.25*data(1); %expected value
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
%fyl = 1.2*data(4); % expected value
bst_tangent = data(5);
ful = data(6);
Est = data(7);
% transverse steel
fyh = data(8);
%fyh = 1.2*data(8); %expected value

% section geomerty and reinforcement
b = data(9); % square section
h = data(10);
ccover = data(11);

% transverse reinforcement
phi_tr = data(12);
rho_tr = data(13);
legs = data(14);
s = data(15);
sclear = s - phi_tr;
Abar_t = pi*phi_tr^2/4;

% longitudinal reinforcement
phi_l = data(16);
rho_l = data(17);
nx = data(18); % number of long. bars per direction
ntotal = data(19);

Abar_l = pi*phi_l^2/4;
wi = (h - (ccover*2)-(legs*phi_tr)-(nx*phi_l))/(nx-1); % clear long. bar spacing
As = ntotal*Abar_l;

% column length
L = data(20);

% imposed axial load
Q = data(21);
eta = Q/(f_c*b*h);

config = data(22);

%%% calculate some geometric parameters
[As_vec,d_vec,d,rho_vec,dFardis] = colRftGeometry(Abar_l,config,phi_l,phi_tr,ccover,b,h,ntotal,nx);
%cover to long. steel NA
cover = ccover + 0.5*phi_tr;
steellayer = ccover + phi_tr + 0.5*phi_l;
% core dimensions
dc = h - (ccover*2) - phi_tr;
bc = b - (ccover*2) - phi_tr;

rho_l_core = As/(bc*dc); % ratio of long. reinf. to core area

% if config == 1 || config == 4 || config == 5 || config == 6 || config == 7
%     Astx = legs*Abar_t; % total area of transverse reinf in one direction
% elseif config == 2 || config == 3
%         Astx = (legs/2 + (legs/2)*sqrt(2))*Abar_t; % double check this later %%%%%%%%%%%%%%
% end

Astx = legs*Abar_t; % total area of transverse reinf in one direction

%rho_x = Astx/(dc*s);  % area ratio of transverse reinforcement to core per direction
rho_tr_area = Astx/(b*s); % total area ratio of transverse reinf for a square section
%%%%%%%%%%%%% note: change dc to b for consistency with Haselton

end

