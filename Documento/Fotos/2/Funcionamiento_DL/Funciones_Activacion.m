clc;
clear all;
close all;

load('z_softmax.dat');
load('z_softmax_1.dat');
load('z_softmax_2.dat');
load('z_softmax_3.dat');
load('z_softmax_4.dat');
soft = 1*z_softmax_1 + 1*z_softmax_2 - 1*z_softmax_3 - 1*z_softmax_4 +0.2;
plane = zeros(200,200) + 0.5;

h = figure();
surf(z_softmax,'FaceAlpha',0.75,'EdgeColor','none')
%colorbar
hold on
surf(plane,'FaceAlpha',0.75,'EdgeColor','none','FaceColor','k')

%xlabel('Tiempo','Interpreter','latex')
%ylabel('Deformacion','Interpreter','latex')
title(['\textbf{Funcion Sigmoid}'],'Interpreter','latex')
%legend(leg)

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'single_sigmoid_top','-dpdf','-r0')
%}