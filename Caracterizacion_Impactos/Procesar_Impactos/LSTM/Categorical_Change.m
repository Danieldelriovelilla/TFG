function [Labels_Pred] = Categorical_Change(scores,Labels_Pred,Damages)

%   Damages = num2str(Damages);
    [maxim, mpos] = max(scores);  %Find the position of the max scores = prediction+
    
%     if isequal(class(Labels_Pred),class(mpos))
%         for i = 1:length(Damages)     %Give a label to each prediction, instead a 1/0        
%             Positions = find(mpos == i)';
%             Num_Labels(Positions,:) = Damages(i);
%         end    
%     else
%         
%     end 

%   Num_Label = Output_Labels;
    Doubt = categorical({'?'});
    for i = 1:length(Labels_Pred)
        if (maxim(i) < 0.6)
            Labels_Pred(i,1) = Doubt;
        else
            %Output_Labels(i,1) = {num2str(Num_Labels(i))};
        end
    end
    
end