clear all
close all
clc

data_path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\INESASSE\Real\FBG\';
load([data_path 'Mean-1to10_Min-Load-30.mat'])

mean = 5;

Tr_La = LSTM(mean).Type_La_Tr;
Tr_St = LSTM(mean).Type_St_Tr;
Va_La = LSTM(mean).Type_La_Val;
Va_St = LSTM(mean).Type_St_Val;

categ = categories(Tr_La);

%% TRAINING SET

labels_num = zeros(size(Tr_La));
for i = 1:length(categ)
    labels_num(find(Tr_La == categ{i})) = i;
end
training_data = cell2mat(Tr_St(:));

training = cat(2, labels_num, training_data);


%% VALIDATION SET

labels_num = zeros(size(Va_La));
for i = 1:length(categ)
    labels_num(find(Va_La == categ{i})) = i;
end
validation_data = cell2mat(Va_St(:));

validation = cat(2, labels_num, validation_data);

save([data_path 'Type_INESASSE.mat'], 'training', 'validation')

%save('strains_labels_cells', 'training_data', 'training_labels', ...
%    'validation_data', 'validation_labels')