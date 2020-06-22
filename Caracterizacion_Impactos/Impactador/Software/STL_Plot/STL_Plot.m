clc;
clear all;
close all;

model = createpde;  %('structural');      %structuralmodel = createpde('structural',StructuralAnalysisType)
g = importGeometry(model,'A380_Rib.stl');

%Rx = rotx(0);
%Ry = roty(0);
%Rz = rotz(phi);
%R = Rx*Ry*Rz;

pdegplot(model,'FaceLabels','off','FaceAlpha',1)
%pdegplot(model,'FaceLabels','on')

%geo = model.Geometry;

%
%a = createpde;
%importGeometry(a,'Rib.stl');