clc;
clear all;
close all;


%% DEFINE AND PLOT MAIN SURFACE
model = createpde;  %('structural');      %structuralmodel = createpde('structural',StructuralAnalysisType)
g = importGeometry(model,'A380_Rib.stl');

A = [0,0,0]; B = [0,790,0]; C = [873,-60,0]; D = [889,745,0];
Nex = 7;
Ney = 6;
[Coor, Grid, Centers] = Grid_Processor(A, B, C, D, Nex, Ney);

% figure()
% Grid_Plot(Coor, Grid, Centers, 0, 0);
% Cylinder(Centers, 1,1,0)


%% SERIAL COMUNICATION
% Serial = serial('COM7','BAUD', 115200);
% 
% fclose(Serial);
% fopen(Serial);
% 
% fscanf(Serial)
% fscanf(Serial)
% fscanf(Serial)

%Disable limits
% Instruction(Serial, '$20=0')
% Instruction(Serial, '$21=0')

%% PLOT SIMULATION
figure()
for i = 1:Nex
    for j = 1:Ney  
        axis([-100 900 -100 900 -100 300])
%         Instruction(Serial, ['G0 X' num2str(Centers{i,j}(1)) ' Y' num2str(Centers{i,j}(2)) ' Z50'])
            pause(2)
%             Instruction(Serial, '?')
        Grid_Plot(Coor,Grid,Centers,model,i,j);
        hold on
        Cylinder(Centers, i,j,50);
         
%         Instruction(Serial, 'G0 Z0')
            pause(2)
%             Instruction(Serial, '?')        
        Grid_Plot(Coor,Grid,Centers,model,i,j);
        hold on
        Cylinder(Centers, i,j,0);
%         
%         Instruction(Serial, 'G0 Z50')
            pause(2)  
%             Instruction(Serial, '?')
        Grid_Plot(Coor,Grid,Centers,model,i,j);
        hold on
        Cylinder(Centers, i,j,50);         
    end
    pause(10)
end




%% GENERATE THE CYLINDER
%{
% Radius =2
R=25;
%Base at (2,0,1)
x0=0;y0=0;z0=10;
% Height = 10
h=500;
[x,y,z] = cylinder(R);
x=x+centers{1,4}(1);
y=y+centers{1,4}(2);
z=z*h+centers{1,4}(3)+z0;
% to plot
c = surf(x,y,z);

c.FaceAlpha = 0.5;           % remove the transparency
c.FaceColor = 'interp';    % set the face colors to be interpolated
c.LineStyle = 'none';      % remove the lines
colormap(white) 
l = light('Position',[-0.4 0.2 0.9],'Style','infinite');
lighting gouraud;
%axis equal off;
material shiny;

hold off


%% ANIMATION

figure()
[X,Y] = meshgrid(linspace(-15, 15, 50));
fcn = @(x,y,k) k*x.^2 + y.^2;
v = [1:-0.05:-1;  -1:0.05:1];
for k1 = 1:2
    for k2 = v(k1,:)
        surfc(X, Y, fcn(X,Y,k2))
        axis([-15  15    -15  15    -300  500])
        drawnow
        pause(0.1)
    end
end



view(-151,30);
axis equal off;
l = light('Position',[-0.4 0.2 0.9],'Style','infinite');
lighting gouraud;
material shiny;
%}