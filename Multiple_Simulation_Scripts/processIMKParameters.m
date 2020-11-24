function [A_ele,E_ele,I_ele,I_mem,K_spr,a_spr,My_spr_pos,Lambda_S,Lambda_C,...
        theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = processIMKParameters(memName,L)
    
    n = 10.0;

    load(memName,'A_ele','E_ele','I_mem','My_spr_pos','McoverMy','Lambda_S','Lambda_C',...
        'theta_p_spr','theta_pc_spr','theta_u_spr','Res_spr');
%     Lambda_S = 0.2;
%     Lambda_C = Lambda_S;
    I_ele = (n+1)/n*I_mem;
    Ke_mem = 6.0*E_ele*I_mem/L;
    Ke_ele = 6.0*E_ele*I_ele/L;
    K_spr = n*Ke_ele;
    
    theta_y = My_spr_pos/Ke_mem;

    % hardening stiffness Ks
    Ks_mem = Ke_mem*theta_y/theta_p_spr*(McoverMy - 1);
    a_mem = Ks_mem/Ke_mem;
    
    if a_mem < 0.0
    a_mem = 0.00001;
    end

    a_spr = a_mem/(1 + n*(1 - a_mem));
end
    
    
    
    