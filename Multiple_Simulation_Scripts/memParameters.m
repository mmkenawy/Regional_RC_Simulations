function [] = memParameters(storyinfo,Lbeam,useIMKCalibration,Nbay,inputunits)
% calibrate elements and springs and write member and spring parameters to
% a .tcl file

Nstory = length(storyinfo);
fileID = fopen('memParameters.tcl','w');
%fileID2 = fopen('memParameters.tcl','w');
for i = 1:Nstory
    type = 'column';
    memName = storyinfo(i).colName;
    L = storyinfo(i).Hcol;
    for j = 1:Nbay + 1
        coltotload = storyinfo(i).coltotLoad(j);
      
        if useIMKCalibration == 1
            [A_ele,E_ele,I_ele,I_mem,K_spr,a_spr,My_spr_pos,Lambda_S,Lambda_C,...
            theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = IMKCalibration(memName,L,coltotload,inputunits);
        else
            [A_ele,E_ele,I_ele,I_mem,K_spr,a_spr,My_spr_pos,Lambda_S,Lambda_C,...
            theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = processIMKParameters(memName,L);
        end
        

    fprintf(fileID,'# Properties of floor %d bay %d column \n',i,j);
    fprintf(fileID,'set A_eleC%d%d %4.3f;\n',i,j,A_ele);
    fprintf(fileID,'set E_eleC%d%d %4.3f;\n',i,j,E_ele);
    fprintf(fileID,'set I_eleC%d%d %4.3f;\n',i,j,I_ele);
    fprintf(fileID,'# I_memC%d%d = %4.3f; just fyi\n',i,j,I_mem);
    fprintf(fileID,'set K_sprC%d%d %4.3f;\n',i,j,K_spr);
    fprintf(fileID,'set a_sprC%d%d %4.6f;\n',i,j,a_spr);
    fprintf(fileID,'set My_spr_posC%d%d %4.3f;\n',i,j,My_spr_pos);
    fprintf(fileID,'set Lambda_SC%d%d %4.3f;\n',i,j,Lambda_S);
    fprintf(fileID,'set Lambda_CC%d%d %4.3f;\n',i,j,Lambda_C);
    fprintf(fileID,'set theta_p_sprC%d%d %4.5f;\n',i,j,theta_p_spr);
    fprintf(fileID,'set theta_pc_sprC%d%d %4.5f;\n',i,j,theta_pc_spr);
    fprintf(fileID,'set theta_u_sprC%d%d %4.5f;\n',i,j,theta_u_spr);
    end
    
%     A_eleC_lst(i) = A_ele;
%     E_eleC_lst(i) = E_ele;
%     I_eleC_lst(i) = I_ele;
%     K_sprC_lst(i) = K_spr;
%     a_sprC_lst(i) = a_spr;
%     My_spr_posC_lst(i) = My_spr_pos;
%     Lambda_SC_lst(i) = Lambda_S;
%     Lambda_CC_lst(i) = Lambda_C;
%     theta_p_sprC_lst(i) = theta_p_spr;
%     theta_pc_sprC_lst(i) = theta_pc_spr;
%     theta_u_sprC_lst(i) = theta_u_spr;
    
    type = 'beam';
    axialLoad = 0.0;
    memName = storyinfo(i).beamName;
    if useIMKCalibration == 1
        [A_ele,E_ele,I_ele,I_mem,K_spr,a_spr,My_spr_pos,Lambda_S,Lambda_C,...
        theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = IMKCalibration(memName,Lbeam,axialLoad,inputunits);
    else
        [A_ele,E_ele,I_ele,I_mem,K_spr,a_spr,My_spr_pos,Lambda_S,Lambda_C,...
        theta_p_spr,theta_pc_spr,theta_u_spr,Res_spr] = processIMKParameters(memName,Lbeam);
    end

    fprintf(fileID,'# Properties of floor %d beams \n',i);
    fprintf(fileID,'set A_eleB%d %4.3f;\n',i,A_ele);
    fprintf(fileID,'set E_eleB%d %4.3f;\n',i,E_ele);
    fprintf(fileID,'set I_eleB%d %4.3f;\n',i,I_ele);
    fprintf(fileID,'# I_memB%d = %4.3f; just fyi\n',i,I_mem);
    fprintf(fileID,'set K_sprB%d %4.3f;\n',i,K_spr);
    fprintf(fileID,'set a_sprB%d %4.6f;\n',i,a_spr);
    fprintf(fileID,'set My_spr_posB%d %4.3f;\n',i,My_spr_pos);
    fprintf(fileID,'set Lambda_SB%d %4.3f;\n',i,Lambda_S);
    fprintf(fileID,'set Lambda_CB%d %4.3f;\n',i,Lambda_C);
    fprintf(fileID,'set theta_p_sprB%d %4.5f;\n',i,theta_p_spr);
    fprintf(fileID,'set theta_pc_sprB%d %4.5f;\n',i,theta_pc_spr);
    fprintf(fileID,'set theta_u_sprB%d %4.5f;\n',i,theta_u_spr);
    
end

% set residual moment ratio for all members
fprintf(fileID,'set ResP %4.4f;\n',Res_spr);
fprintf(fileID,'set ResN %4.4f;\n',Res_spr);
    
%  fprintf(fileID2,'# Properties of floor all columns \n');
%     fprintf(fileID2,'set A_eleC "');
%     fprintf(fileID2,'%4.3f ',A_eleC_lst);
%     fprintf(fileID2,'";\n');

fclose(fileID);
%fclose(fileID2);
end