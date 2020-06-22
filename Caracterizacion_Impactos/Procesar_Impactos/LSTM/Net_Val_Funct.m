function [Error_Val] = Net_Val_Funct(Data_Val,Labels_Val,miniBatchSize,LSTM_net)

    %LOAD NET & DATA

    XTest = Data_Val;
    YTest = Labels_Val;

    
    % DATA ORGANIZATION

    numObservationsTest = numel(XTest);
    for i=1:numObservationsTest
        sequence = XTest{i};
        sequenceLengthsTest(i) = size(sequence,2);
    end
    [sequenceLengthsTest,idx] = sort(sequenceLengthsTest);
    XTest = XTest(idx);
    YTest = YTest(idx);


    % NETWORK VALIDATION

    [Labels_Pred_Val, scores_Val] = classify(LSTM_net,XTest,...
                            'ExecutionEnvironment','parallel',...
                            'MiniBatchSize',miniBatchSize, ...
                            'SequenceLength','longest');
    
%      [Labels_Pred_Tr, scores_Tr] = classify(LSTM_net,XTest,...
%                             'ExecutionEnvironment','gpu',...
%                             'MiniBatchSize',miniBatchSize, ...
%                             'SequenceLength','longest');
    
    prompt = 'Do you want to give a "?" label if the predicted score is < 0.6? Y/N: ';    %Ask for training
    str = input(prompt,'s');
    if (str == 'Y')
        Labels_Pred_Val = Categorical_Change(scores_Val',Labels_Pred_Val);
    else
    end

    Error_Val = mean(Labels_Pred_Val ~= YTest);
    disp("Validation error: " + Error_Val*100 + "%")
%     trainError = mean(Labels_Pred_Tr ~= YTest);
%     disp("Training error: " + trainError*100 + "%")
    



    % PLOTS
    
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
