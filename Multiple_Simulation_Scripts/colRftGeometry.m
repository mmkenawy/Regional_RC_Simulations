function [As_vec,d_vec,d,rho_vec,dFardis] = colRftGeometry(Abar_l,config,phi_l,phi_tr,ccover,b,h,ntotal,nx)

% Geometric parameters: determine locations of steel rft and other related parameters based on the
% configuration number
%%%%%%%%%%%%% Description of the column configurations
%%%%%% Config 7: nonuniform column reinforcement with nx bars at the top
%%%%%% and bottom, and ntotal number of bars. The intermediate
%%%%%% reinforcement is divided over two layers.
if config == 1 || config == 2
    As1 = nx*Abar_l;
    As2 = (ntotal - nx*2)/2*Abar_l;
    As3 = (ntotal - nx*2)/2*Abar_l;
    As4 = nx*Abar_l;
    
    spacing = (h - 2*ccover - 2*phi_tr - phi_l)/3;
    d1 = ccover + phi_tr + 0.5*phi_l;
    d2 = d1 + spacing;
    d3 = d2 + spacing;
    %d = d3 + spacing;
    d = h - ccover - phi_tr - 0.5*phi_l;
    dFardis = h - ccover;
    
elseif config == 3 || config == 4 || config == 6
    As1 = 3*Abar_l;
    As2 = 2*Abar_l;
    As3 = 0.0;
    As4 = 3*Abar_l;
    
    spacing = (h - 2*ccover - 2*phi_tr - phi_l)/2;
    d1 = ccover + phi_tr + phi_l/2;
    d2 = d1 + spacing;
    d3 = d2;
    %d = d3 + spacing;
    d = h - ccover - phi_tr - 0.5*phi_l;
    dFardis = h - ccover;
    
    elseif config == 5
    As1 = 2*Abar_l;
    As2 = 0.0;
    As3 = 0.0;
    As4 = 2*Abar_l;
    
    spacing = h - 2*ccover - 2*phi_tr - phi_l;
    d1 = ccover + phi_tr + phi_l/2;
    d2 = d1 + spacing;
    d3 = d2;
    %d = d3;
    d = h - ccover - phi_tr - 0.5*phi_l;
    dFardis = h - ccover;
    
    elseif config == 7
    As1 = nx*Abar_l;
    As2 = (ntotal - 2*nx)/2*Abar_l; % total number of bars minus twice the number of bars per side(top
    % or bottom) over two sides over two intermediate layers.
    As3 = (ntotal - 2*nx)/2*Abar_l;
    As4 = nx*Abar_l;
    
    spacing = (h - 2*ccover - 2*phi_tr - phi_l)/3;
    d1 = ccover + phi_tr + 0.5*phi_l;
    d2 = d1 + spacing;
    d3 = d2 + spacing;
    %d = d3 + spacing;
    d = h - ccover - phi_tr - 0.5*phi_l;
    dFardis = h - ccover;
else

    disp('Enter a valid column configuration number (an integer between 1 and 7)')
end

%compute reinforcement ratios - normalized by b* effective depth (i.e.,
%depth to tension steel)
% to follow the nomenclature in Panagiotakos and Fardis 2001, the different
% reinforcement ratios are determined by dividing the uniform reinforcement
% by 3. 
    %As_tot = As1 + As2 + As3 + As4;
    rhoc = As1/(b*d); % compression reinforcement
    rhow = (As2 + As3)/(b*d); % web reinforcement (anything between tension and compression)
    rhot = As4/(b*d); % tension reinforcement
    
% reinforcement areas (all four rows)
As_vec = [As1,As2,As3,As4];
% reinforcement distances(all four rows)
d_vec = [d1,d2,d3,d];
% reinforcement ratios (comp, tension and web)
rho_vec = [rhoc,rhow,rhot];

end