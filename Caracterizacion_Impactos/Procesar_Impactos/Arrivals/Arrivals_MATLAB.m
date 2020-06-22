clc;
clear all;
close all;

%% LOAD FILES
Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Impact_Processor\Preprocessor\A380_Pasive\Ni-6366\Impactos 33J y 50J A380\A380_Impact_1';
Folder = [Path '\events'];
Files = dir(Folder);
Events = struct('Data', [], 'Label', []);

for i = 3:length(Files)%74   %en el de baja energia hasta 74 porque hay otra carpeta
    Single_Event = struct2cell(open([Files(i).folder '\' Files(i).name]));
    for j = 1:length(Single_Event)-1
        Events.Data = cat(1,Events.Data,{Single_Event{j}.Data});
        Events.Label = cat(1,Events.Label,categorical({Files(i).name(1:2)}));
    end
end


%%

%Chrisrian variables
predamage=5000; % number op points before the Max
threshold = 0.05;
Total_Samples = 200;

for k = 1:length(Events.Data)
    Impact = Events.Data{k}';
    %Detect arrival times
    for i = 1:8
        avr = mean(Impact(i,1:601));
        Impact(i,:) = Impact(i,:) - avr;
        [Max_val(i), Max_id(i)] = max(Impact(i,:));

        if Max_id(i) > predamage
            Max_id(i) = Max_id(i) - predamage;
        end

        for j = 1:length(Impact)
            if abs(Impact(i,j)) > threshold
                Trigger(i) = j;
                break
            end        
        end
        %Arrivals(i) = Trigger(i) + Max_id(i);
    end

    %Reorganize the arrival times
    [First_Arrival_Val, First_Arrival_id] = min(Trigger);
    Init = First_Arrival_Val;
    End = Init + Total_Samples;

    Impact(:,1:Init) = [];
    Impact(:,Total_Samples+1:end) = [];
    %{
    figure()
    for i = 1:8
        plot(Impact(i,:));
        hold on;
    end
    %}
    Events.Processed{k,1} = Impact;
end

Processed.Data = Events.Processed;
Processed.Labels = Events.Label;



%%  PREPARE NET DATA

[Processed.Data_Val, Processed.Labels_Val, Processed.Data_Tr, Processed.Labels_Tr]...
          = Split_Train_Val(15, Processed.Data, Processed.Labels);


save('Data\Events_Processed','Processed')