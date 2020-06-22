%-------------------------------------------------------------------------%
%    MATLAB Code for Serial Communication between Arduino and MATLAB      %
%                             5 axes test                                 %
clc;
close all;
clear all;

Serial = serial('COM7','BAUD', 115200);

fclose(Serial);
fopen(Serial);

fscanf(Serial)
fscanf(Serial)
fscanf(Serial)

%fread(Serial)
%go = true;

%G92  X0 Y0 Z0 to set manually the origin