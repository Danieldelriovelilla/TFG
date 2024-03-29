clear all
close all
clc

Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\DACOMAT\';
load([Data_Path 'LSTM_Data.mat'])


Tr_La = LSTM.Type_La_Tr;
Tr_St = LSTM.Type_St_Tr;
Va_La = LSTM.Type_La_Val;
Va_St = LSTM.Type_St_Val;

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

save([Data_Path 'Type_DACOMAT.mat'], 'training', 'validation')