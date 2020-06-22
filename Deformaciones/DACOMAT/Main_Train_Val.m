%%   PROGRAM DESCRIPTION   %
%{
    You can select the NHU, mxEpoch and minBS and train a net with the deta
    at the Data_Path folder.
    After the training process, the validation results are plotted.
%}

clc;
clear all;
close all;

%% CREATE LSTM_Style OBJECT

LSTM_Style = LSTM_Style;


%% CARGAR DATOS FBG %%

Folder_Path = 'Data\';
File_Name = 'LSTM_Data.mat';
load([Folder_Path File_Name])


%Give the correct variable names to the data
Data_Tr = LSTM.Type_St_Tr;
Labels_Tr = LSTM.Type_La_Tr;
Data_Val = LSTM.Type_St_Val;
Labels_Val = LSTM.Type_La_Val;
Data = LSTM.Type_St_Te;
Labels = LSTM.Type_La_Te;



%% NEURONAS E ITERACIONES %%

numHiddenUnits = 100;
maxEpochs = 100;
miniBatchSize = 10;


%Select TRAIN and VALIDATON options
prompt = 'Do you want to perform a TRAINING? Y/N: ';    %Ask for training
str = input(prompt,'s');

if (str == 'Y')
    LSTM_net = Training(LSTM_Style,Data_Tr,Labels_Tr,Data_Val,Labels_Val,...
               numHiddenUnits,maxEpochs,miniBatchSize); 
else
    load(['Nets\LSTM_Net_NHU-' num2str(numHiddenUnits) '_MxE-' num2str(maxEpochs) '.mat']);    
end

Val_Error = Accuracy(LSTM_Style,Data_Val,Labels_Val,miniBatchSize,LSTM_net);
Train_Error = Accuracy(LSTM_Style,Data,Labels,miniBatchSize,LSTM_net);




%{
%% FULL VALIDATION


[Output_Labels,scores] = classify(LSTM_net,Data_Tr,...  
                                 'ExecutionEnvironment','auto',...
                                 'SequenceLength','longest',...
                                 'MiniBatchSize', miniBatchSize);

    Cell_Output = cellstr(Output_Labels);
    Cell_Target = cellstr(Labels_Tr);
%{
    for i = 1:length(Output_Labels)
        Num_Output(i,1) = str2num(Cell_Output{i});
        Num_Target(i,1) = str2num(Cell_Target{i});
    end
%}

[maxim, mpos] = max(scores');  %Find the position of the max scores = prediction

prompt = 'Do you want to give a "?" label if the predicted score is < 0.6? Y/N: ';    %Ask for training
str = input(prompt,'s');
if (str == 'Y')
    
    for i = 1:length(maxim)
        if (maxim(i) < 0.6)
            Output_Labels(i) = {'?'};
        else
        end
    end
    
end

Output_Labels = categorical(Output_Labels);

%Error
Validation_Error = mean(Output_Labels ~= Labels_Tr);
disp("Training error: " + Validation_Error*100 + "%")

%Confusion matrix
figure()
plotconfusion(Labels_Tr,Output_Labels)
xlabel('\textbf{Target class}','interpreter','latex'); 
ylabel('\textbf{Output class}','interpreter','latex');
title('\textbf{REAL DATA: VALIDATION CONFUSION MATRIX}','interpreter','latex')

figure()
cm = confusionchart(Labels_Tr,Output_Labels, ...
    'Title',['ACCURACY = ' num2str(100 - Validation_Error*100) ' %'], ...
    'RowSummary','row-normalized', ...
    'ColumnSummary','column-normalized');


%Prediction plot
figure()
plot(Num_Target,'o')
hold on
plot(Num_Output,'o')
hold off
%}
    
%{
%% PLOT RESULTS

figure()
for i = 1:length(numHiddenUnits)
    plot(maxEpochs,Val_Error(i,:)*100,'o-','DisplayName',num2str(numHiddenUnits(i)))
    hold on
end
grid on

title('Error vs max Eporch & Hidden Units')
xlabel('Epochs')
ylabel('Validation Error (%)')

lgd = legend('Location','best','AutoUpdate','off');
title(lgd,['Num Hidden Units']);


%Confusion
load(['Nets\OBR_Net_Deeper_NHU-' num2str(numHiddenUnits1) '-' num2str(numHiddenUnits2) '_MxE-' num2str(maxEpochs) '.mat']);

    
Output_Labels = classify(LSTM_net,All_Data,...
        'ExecutionEnvironment','gpu',...
        'MiniBatchSize',miniBatchSize, ...
        'SequenceLength','longest');
    
Target_Labels = All_Label;    
plotconfusion(Target_Labels,Output_Labels)
    xlabel('\textbf{Target class}','interpreter','latex'); 
    ylabel('\textbf{Output class}','interpreter','latex');
    title('\textbf{CONFUSION MATRIX: OBR-FEM}','interpreter','latex')
%}