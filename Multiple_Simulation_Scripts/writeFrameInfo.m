function [] = writeFrameInfo(buildingName,Nstory,Nbay,Hcol1,Hcol2,Lbeam,storyinfo,PDeltaCol,...
    analysisType,g,inputunits)
% write frame info to a .tcl file

fileID = fopen('frameInfo.tcl','w');

fprintf(fileID,'set buildingName %s;\n',buildingName);
fprintf(fileID,'set analysisType %s;\n',analysisType);
fprintf(fileID,'set Nstory %d;\n',Nstory);
fprintf(fileID,'set Nbay %d;\n',Nbay);
fprintf(fileID,'set Hcol1 %4.3f;\n',Hcol1);
fprintf(fileID,'set Hcol2 %4.3f;\n',Hcol2);
fprintf(fileID,'set Lbeam %4.3f;\n',Lbeam);
fprintf(fileID,'set PDeltaCol %d;\n',PDeltaCol);
fprintf(fileID,'set g %4.2f;\n',g);
fprintf(fileID,'set units %d;\n',inputunits);


for i = 1:Nstory
    for j = 1:Nbay + 1
    fprintf(fileID,'set nodalMass%d%d %4.6f;\n',i+1,j,storyinfo(i).nodalmass(j));
    end
    fprintf(fileID,'set floorWeight%d %4.6f;\n',i,storyinfo(i).weight);
    fprintf(fileID,'set beamUniform%d %4.6f;\n',i,storyinfo(i).fac_beamUniform);
    fprintf(fileID,'set colUniform%d %4.6f;\n',i,storyinfo(i).fac_colUniform);
    
end

fclose(fileID);
end