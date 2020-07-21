clear all
close all
clc

Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Impactos\A380_Christian\';
load([Data_Path 'Events_Processed.mat'])

data = Processed.Data;
labels = Processed.Labels;
categ = categories(labels);



for category = 1:length(categ)
    pos = find(labels == categ{category});
    for i = 1:length(pos)
        impacts(i,:,:) = data{pos(i)};
    end
    save([Data_Path categ{category} '.mat'], 'impacts')
    clear impacts
end

%{
Tr_La = LSTM.Load_La_Tr;
Tr_St = LSTM.Load_St_Tr;
Va_La = LSTM.Load_La_Val;
Va_St = LSTM.Load_St_Val;



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

save([Data_Path 'Load_OBR_INESASSE.mat'], 'training', 'validation')


%% T-SNE

validation(:,1) = [];
Y = tsne(validation);
gscatter(Y(:,1),Y(:,2),Va_La,'rkgbg','o*s^dx')

%}