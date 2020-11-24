function [] = colSectionInfo(buildingName,colSecs,useIMKCalibration,inputunits)
% read and store beam and column section info
for i = 1:colSecs
    colName = [buildingName,'_C',num2str(i)];
    if useIMKCalibration == 1
        [ f_c,e_co,e_zero_ucc,Ec,fyl,bst_tangent,ful,Est,fyh,b,h,ccover,phi_tr,...
        rho_tr,legs,s,sclear,Abar_t,phi_l,rho_l,nx,ntotal,Abar_l,...
        wi,As,dc,bc,rho_l_core,L,cover,Q,steellayer,rho_tr_area,config,eta,Astx,...
        As_vec,d_vec,d,rho_vec,dFardis] = readcoldata(colName,inputunits);
    else
        [A_ele,E_ele,I_mem,My_spr_pos,McoverMy,Lambda_S,Lambda_C,...
        theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = readIMKParameters(colName);
    end
    save(colName)
end
end