function [LSTM_net] = Net_Train_Funct(Train_Data, Train_Label, Val_Data, Val_Label, ...
                      numHiddenUnits, maxEpochs, miniBatchSize)


    %{
    %% PADDING DATA
    %Solo necesario cuando la longitud de los vectores no es la misma

    %Get the sequence lengths for each observation.
    numObservations = numel(Train_Data);
    for i = 1:numObservations
        sequence =  Train_Data{i};
        sequenceLengths(i) = size(sequence,2);
    end

    %Sort the data by sequence length.
    [sequenceLengths,idx] = sort(sequenceLengths);
    Train_Data =  Train_Data(idx);
    Train_Label = Train_Label(idx);

    %View the sorted sequence lengths in a bar chart.
    %{
    figure
    bar(sequenceLengths)
    ylim([0 30])
    xlabel("Sequence")
    ylabel("Length")
    title("Sorted Data")
    %}
%}

    %% NET DEFINITION
    
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
    
    options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'InitialLearnRate',1e-4, ...
        'GradientThreshold',1, ...
        'Shuffle','every-epoch', ...
        'ValidationData',{Val_Data,Val_Label}, ...
        'ValidationFrequency',numIterationsPerEpoch, ...        
        'Plots','training-progress',...
        'Verbose',false, ...
        'ExecutionEnvironment','parallel', ...
        'MaxEpochs',maxEpochs, ...
        'SequenceLength','longest');

    LSTM_net = trainNetwork(Train_Data, Train_Label,layers,options);

    Path_Folder = 'Nets\';
    save([Path_Folder 'LSTM_Net_NHU-' num2str(numHiddenUnits) '_MxE-' num2str(maxEpochs) '.mat'],'LSTM_net')





    %% PLOT GRAPH
    %{
    layers = [
        imageInputLayer([32 32 3],'Name','Input Layer')   
        convolution2dLayer(3,16,'Padding','same','Name','biLSTM 125 neurons')
        batchNormalizationLayer('Name','Dropout_1')
        reluLayer('Name','biLSTM 100 neurons')

        convolution2dLayer(3,16,'Padding','same','Stride',2,'Name','Dropout_2')
        batchNormalizationLayer('Name','Fully Connected')
        reluLayer('Name','Softmax') 
        additionLayer(2,'Name','Classification')];

    lgraph = layerGraph(layers);
    %lgraph = connectLayers(lgraph,'relu_1','add/in2');

    figure
    plot(lgraph);
    title('\textbf{LAYER GRAPH: 2 biLSTM LAYERS}','interpreter','latex')
    axis('off');
    %}
    
end