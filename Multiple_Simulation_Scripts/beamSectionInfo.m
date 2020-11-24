function [] = beamSectionInfo(buildingName,beamSecs,useIMKCalibration,inputunits)
% read and store beam section info

for i = 1:beamSecs
    beamName = [buildingName,'_B',num2str(i)];
    if useIMKCalibration == 1
        [ f_c,e_co,e_zero_ucc,Ec,fyl,bst_tangent,Est,fyh,b,h,topccover,btmccover,...
        phi_tr,legs,s,sclear,Abar_tr,phi_top,phi_btm,phi_l,rho_top,rho_btm,ntop,nbtm,...
        ntotal,Abar_top,Abar_btm,nxtop,nxbtm,wi,As_top,As_btm,Astotal,dc,bc,rho_l_core,L,...
        Q,steellayer_top,steellayer_btm,rho_tr_area,config,eta,Astx,...
        As_vec,d_vec,d,rho_vec,dFardis] = readbeamdata(beamName,inputunits);
   else
        [A_ele,E_ele,I_mem,My_spr_pos,McoverMy,Lambda_S,Lambda_C,...
        theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = readIMKParameters(beamName);
    end
    save(beamName)
end
end