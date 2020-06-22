%% PROCESS OBR STRAINS AND GENERATE THE PYTHON DATA %%

clc
clear all
close all

%% LOAD DATA STRUCT

Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\INESASSE\Real\OBR\';

load([Data_Path 'OBR_INESASSE'])

Data = rmfield(Data,'Noise');
Data = rmfield(Data,'Noise_Load');

Data(18) = [];
Data(5:8) = [];


for j = 1:14
    figure()
    for i = 1:8
        plot(Data(j).Strains(i,:))
        hold on
    end
    title(Data(j).Dam_Size{:})
    saveas(gcf, ['OBR_Figures/' Data(j).Dam_Size{:} '.png'])
end

