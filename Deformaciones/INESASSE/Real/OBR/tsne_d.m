clc;
clear all;
close all;

data = load('t-sne_Load_OBR_INEsASSE.dat');
load('Load_categ.mat');

labels = unique(data(:,3));
h = figure();
m = ['+','o','*','.','x','s','d','v'];
%m = ['+', 'o', '*','.','x','s','d','v','^','>','<','p',h','+','o','*'];
hold on
for i = 1:length(labels)
    pos = find(data(:,3) == labels(i));
    plot(data(pos(1):pos(end),1),data(pos(1):pos(end),2),m(i),'LineWidth',2)
end
box on
legend()
legend(categ)