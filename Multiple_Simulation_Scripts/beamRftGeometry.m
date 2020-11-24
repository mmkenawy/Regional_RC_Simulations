function [As_vec,d_vec,dFardis,rho_vec] = beamRftGeometry(Abar_top,Abar_btm,config,phi_top,...
    phi_btm,ntop,nbtm,nxtop,nxbtm,phi_tr,topccover,btmccover,b,h)

if config == 8 % only beam config for now
    if nxtop == ntop
        trows = 1; % reinforcement is in one row
    elseif 2*nxtop >= ntop
        trows = 2; % reinforcement is in two rows
    elseif 3*nxtop >= ntop
        trows = 3; % reinforcement is in three rows
    else
        disp('this script can only take three rows of rft - need to modify for more rows')
    end
    
    steellayer_top = topccover + phi_tr + (trows - 0.5)*phi_top;
    d1 = steellayer_top;
    
    if nxbtm == nbtm
        brows = 1; % reinforcement is in one row
    elseif 2*nxbtm >= nbtm
        brows = 2; % reinforcement is in two rows
    elseif 3*nxbtm >= nbtm
        brows = 3; % reinforcement is in three rows
    else
        disp('this script can only take three rows of rft - need to modify for more rows')
    end
    
    steellayer_btm = btmccover + phi_tr + (brows - 0.5)*phi_btm;    
    d = h - steellayer_btm; %effective depth of the section
    
    dFardis = h - btmccover;
    As_top = ntop*Abar_top;
    As_btm = nbtm*Abar_btm;
    
    rho_top = As_top/(b*d);
    rho_btm = As_btm/(b*d);
else
    disp('enter a valid beam configuration');
end
    
% reinforcement areas (all four rows)
As_vec = [As_top,0.0,0.0,As_btm];
% reinforcement distances(all four rows)
d_vec = [d1,0.0,0.0,d];
% reinforcement ratios (comp, tension and web)
rho_vec = [rho_top,0.0,rho_btm];
end

    
    