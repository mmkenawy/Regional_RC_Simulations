function [A_ele,E_ele,I_mem,My_spr_pos,McoverMy,Lambda_S,Lambda_C,...
        theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = readIMKParameters(memName)

    data = xlsread(memName,'C1:C11');
    E_ele = data(1);
    A_ele = data(2);
    I_mem = data(3);
    My_spr_pos = data(4);
    McoverMy = data(5);
    Lambda_S = data(6);
    Lambda_C = data(7);
    theta_p_spr = data(8);
    theta_pc_spr = data(9);
    Res_spr = data(10);
    theta_u_spr = data(11);
end