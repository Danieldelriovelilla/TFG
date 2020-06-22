function [Data_LSTM_Val, Labels_LSTM_Val, Data_LSTM_Tr, Labels_LSTM_Tr]...
          = Split_Train_Val(Per_Val, Data_LSTM, Labels_LSTM)

    msize = numel(Data_LSTM);
    x = round((Per_Val/100)*msize);
    idx = randperm(msize);
    Val_Pos = idx(1:x);

    Data_LSTM_Val = Data_LSTM(Val_Pos);
    Labels_LSTM_Val = Labels_LSTM(Val_Pos);
    Data_LSTM_Tr = Data_LSTM;   Data_LSTM_Tr(Val_Pos) = [];
    Labels_LSTM_Tr = Labels_LSTM;   Labels_LSTM_Tr(Val_Pos) = [];

end