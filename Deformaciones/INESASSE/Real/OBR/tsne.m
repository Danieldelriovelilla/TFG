clc;
clear all;
close all;

data = load('t-sne_Ti_Si_OBR_INEsASSE.dat');
load('categ.mat');

labels = unique(data(:,3));
h = figure();
mar = ['+';'o'];
m = ['+', 'o', '*','.','x','s','d','v','^','>','<','p'...
   'h','+','o','*'];
hold on
for i = 1:length(labels)
    pos = find(data(:,3) == labels(i));
    plot(data(pos(1):pos(end),1),data(pos(1):pos(end),2),m(i),'LineWidth',2)
end
legend(categ)