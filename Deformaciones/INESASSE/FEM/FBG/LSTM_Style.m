%% ----    OBJECT WITH FUNCTIONS    ---- %%

classdef LSTM_Style
    properties
        Value {mustBeNumeric}
    end
    methods
        function LSTM = LSTM_Struct(obj, Struct)
            %Find the Strain field
            fields = fieldnames(Struct);
            if (find(ismember(fields,'Strains')) <= length(fields)) == 1
                %Initializate the LSTM fields
                for i = 1:length(fields)
                    LSTM.(fields{i}) = [];
                end
                %Fill the Strains field just once
                for i = 1:length(Struct)
                    sizes(i) = length(Struct(i).Strains);
                    for i2 = 1:sizes(i)
                        LSTM(1).Strains = [LSTM(1).Strains;{Struct(i).Strains(i2,:)}];
                    end
                end
                %Delete the Strains field
                fields(find(ismember(fields,'Strains'))) = [];
                for i = 1:length(fields)
                    if size(Struct(1).(fields{i})) == [1,1]
                        for i2 = 1:length(Struct)
                            for i3 = 1:sizes(i2)
                                LSTM(1).(fields{i}) = [LSTM(1).(fields{i});Struct(i2).(fields{i})];
                            end
                        end
                    else
                        for i2 = 1:length(Struct)
                            for i3 = 1:sizes(i2)
                                LSTM(1).(fields{i}) = [LSTM(1).(fields{i});Struct(i2).(fields{i})(i3)];
                            end
                        end
                    end
                         
                end
                for i =1:length(fields)
                    LSTM(1).(fields{i}) = categorical(LSTM(1).(fields{i}));
                end
            else        
                disp('No STRAINS field found');
            end
        end
        
        %%    ------------    %%
        
        function [Data_LSTM_Val, Labels_LSTM_Val, Data_LSTM_Tr, Labels_LSTM_Tr]...
                = Split_Train_Val(obj,Per_Val, Data_LSTM, Labels_LSTM)
            %index calculations
            msize = numel(Data_LSTM);
            x = round((Per_Val/100)*msize);
            idx = randperm(msize);
            Val_Pos = sort(idx(1:x));
            %Store the validation samples
            Data_LSTM_Val = Data_LSTM(Val_Pos);
            Labels_LSTM_Val = Labels_LSTM(Val_Pos);
            Data_LSTM_Tr = Data_LSTM;   Data_LSTM_Tr(Val_Pos) = [];
            Labels_LSTM_Tr = Labels_LSTM;   Labels_LSTM_Tr(Val_Pos) = [];
        end
        
        %%    ------------    %%
        
        function LSTM = TrValTe(obj,Struct,Per_Test, Per_Val)
            %Find the Strain field
            fields = fieldnames(Struct);
            if (find(ismember(fields,'Strains')) <= length(fields)) == 1
                LSTM = struct();
                fields(find(ismember(fields,'Strains'))) = [];
                %Pull apart the samples in Training, Validation and Testing
                for i = 1:length(fields)
                    Label_Data = categorical(getfield(Struct,fields{i}));
                    [LSTM(1).([fields{i} '_St_Te']),LSTM(1).([fields{i} '_La_Te']),...
                        Strains, Labels] = obj.Split_Train_Val(Per_Test,Struct.Strains,Label_Data);
                    [LSTM(1).([fields{i} '_St_Val']),LSTM(1).([fields{i} '_La_Val']),...
                        LSTM(1).([fields{i} '_St_Tr']),LSTM(1).([fields{i} '_La_Tr'])]...
                        = obj.Split_Train_Val(Per_Val, Strains, Labels);        
                end
            else        
                disp('Error: LSTM_Struct');
            end
        end
        
        %%    ------------    %%
        
        function LSTM_net = Training(obj,Train_Data, Train_Label, Val_Data, Val_Label, ...
                      numHiddenUnits, maxEpochs, miniBatchSize)
            %Net deffinition    
            inputSize = size(Train_Data{1},1);
            numClasses = size(categories(Train_Label),1);
            layers = [ ...
                sequenceInputLayer(inputSize, 'Name', 'Sequence')
                bilstmLayer(numHiddenUnits,'OutputMode','last', 'Name', 'biLSTM')
                dropoutLayer(0.5,'Name','DropLayer')
                fullyConnectedLayer(numClasses,'Name','FullyConnectedLayers')
                softmaxLayer('Name','Softmax')
                classificationLayer('Name','Classification')];
            numObservations = numel(Train_Data);
            numIterationsPerEpoch = floor(numObservations / miniBatchSize);
            %Training parameters
            options = trainingOptions('adam', ...
                'MiniBatchSize',miniBatchSize, ...
                'InitialLearnRate',1e-4, ...
                'GradientThreshold',1, ...
                'Shuffle','every-epoch', ...
                'ValidationData',{Val_Data,Val_Label}, ...
                'ValidationFrequency',numIterationsPerEpoch, ...
                'Plots','training-progress',...
                'Verbose',false, ...
                'ExecutionEnvironment','gpu', ...
                'MaxEpochs',maxEpochs, ...
                'SequenceLength','longest');
            %Net training initialization
            LSTM_net = trainNetwork(Train_Data, Train_Label,layers,options);
            %Save net
            Path_Folder = 'Nets\';
            save([Path_Folder 'LSTM_Net_NHU-' num2str(numHiddenUnits) '_MxE-' num2str(maxEpochs) '.mat'],'LSTM_net')
        end
        
        %%    ------------    %%
        
        function Error_Val = Accuracy(obj,Data_Val,Labels_Val,miniBatchSize,LSTM_net)
            %Load data            
            XTest = Data_Val;
            YTest = Labels_Val;          
            %Data organization            
            numObservationsTest = numel(XTest);
            for i=1:numObservationsTest
                sequence = XTest{i};
                sequenceLengthsTest(i) = size(sequence,2);
            end
            [sequenceLengthsTest,idx] = sort(sequenceLengthsTest);
            XTest = XTest(idx);
            YTest = YTest(idx);
            %Accuracy test            
            [Labels_Pred_Val, scores_Val] = classify(LSTM_net,XTest,...
                'ExecutionEnvironment','gpu',...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest');
            prompt = 'Do you want to give a "?" label if the predicted score is < 0.6? Y/N: ';    %Ask for training
            str = input(prompt,'s');
            if (str == 'Y')
                Labels_Pred_Val = obj.Categorical_Change(scores_Val',Labels_Pred_Val);
            else
            end
            Error_Val = mean(Labels_Pred_Val ~= YTest);
            disp("Validation error: " + Error_Val*100 + "%")
            %Plots            
            % Confusion matrix
            figure()
            plotconfusion(YTest,Labels_Pred_Val)
            xlabel('\textbf{Target class}','interpreter','latex');
            ylabel('\textbf{Predicted class}','interpreter','latex');
            title('\textbf{REAL DATA: VALIDATION CONFUSION MATRIX}','interpreter','latex')
            % Conbfusion chart
            figure()
            cm = confusionchart(YTest,Labels_Pred_Val, ...
                'Title',['ACCURACY = ' num2str(100 - Error_Val*100) ' %'], ...
                'ColumnSummary','column-normalized', ...
                'RowSummary','row-normalized');
            ylabel('Target class');
        end
        
        %%    ------------    %%
        
        function Labels_Pred = Categorical_Change(obj,scores,Labels_Pred,Damages)   
            %Find the position of the max scores = prediction
            [maxim, mpos] = max(scores);
            Doubt = categorical({'?'});
            for i = 1:length(Labels_Pred)
                if (maxim(i) < 0.6)
                    Labels_Pred(i,1) = Doubt;
                else                    
                end
            end           
        end
    end
end