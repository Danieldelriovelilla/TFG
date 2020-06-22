%% -----------------  EXTRACT STRAINS FROM RPT FILES  ------------------ %%

clc;
clear all;
close all;

%% CREATE LSTM_Style OBJECT

LSTM_Style = LSTM_Style;


%% LOAD FILES

Folder = 'rpt_Files';
Files = dir(Folder);
for i = 1:length(Files)
   FileNames{i,1} = [Folder '\' Files(i).name];
end
FileNames(1:2) = [];

%% DEFINE SENSOR ELEMENTS

S1 = [2948:2997];
S2 = [2648:2697];
S3 = [2348:2397];
%S3 = [3099:2:3177 3178:2:3186 3189:2:3197];
S4 = [200:-1:151];
S5 = [500:-1:451];
S6 = [701:750];
S7 = [1251:1300];
S8 = [951:1000];

%Sensors = [S1; S2; S3; S4; S5; S6; S7; S8]; %Elements number
Sensors = [S3; S4; S5; S6]; %Elements number


%%  PUNCTUAL LOAD  %%

Data = struct('Type', {}, 'Size', {},'Ty_Si', {}, 'Load', {}, 'Ref_Strains', {}, ...
    'TempCoef', {}, 'Strains', {},  'Temp', {}, 'Temperature', {});

load = [0.3:0.1:1];
for i = 1:length(load)
    Load(i,1) = {num2str(load(i))}';
end
Noise = [0:5:25];
repeat = 10;

%Punctual load Strains
figure
for i = 1:length(FileNames)
    Element_Position = [];    
    %Extract the information of the sensors' elements
    RawData = rpt_Reader(FileNames{i,1});
    for i2 = 1:size(Sensors)
        [tf,idx] = ismember(RawData(:,1),Sensors(i2,:));
        Element_Position = cat(1,Element_Position,find(1 == tf));
    end    
    %Load the Data structure with the i values
    Data(i).Type = {FileNames{i,1}(11:13)};
    Data(i).Size = {FileNames{i,1}(15:17)};
    Data(i).Ty_Si = {[Data(i).Type{:} '-' Data(i).Size{:}]};
    Data(i).Temp = {FileNames{i,1}(20:end-4)};
    if rem(i,2) == 0
        strains = RawData(Element_Position,2)'*4*10e2;
        Data(i).TempCoef = (strains_odd - strains)/...
            (str2num(Data(i-1).Temp{:}) - str2num(Data(i).Temp{:}));
    else
        strains = RawData(Element_Position,2)'*4*10e2;
        strains_odd = strains;
    end    
    plot(strains)
    hold on
    %Increase the Sample number with noise -> Gusian or Random
    for i2 = 1:length(load)
        Data(i).Ref_Strains = [Data(i).Ref_Strains; repmat(strains*load(i2),repeat,1)];%...
            %+ wgn(repeat,length(strains),-15)];
        for j2 = 1:repeat
            Data(i).Load = [Data(i).Load; Load(i2)];
        end    
    end
end

   
%%  THERMAL LOAD  %%

Tr = 180;
dT = [-10:10:40] - Tr;
Data_T = Data(2:2:end);

figure()
for i = 1:length(Data_T)    %Link temperature change and the deformation
    %Thermal strains
    for i2 = 1:length(dT)
        Data_T(i).Strains = [Data_T(i).Strains; Data_T(i).Ref_Strains + ...
            repmat(Data_T(i).TempCoef*dT(i2),size(Data_T(1).Ref_Strains,1),1)];
%         for i3 = 1:size(Data_T(1).Ref_Strains,1)
%             Data_T(i).Temperature = [Data_T(i).Temperature;...
%                 {[num2str(dT(i2) + Tr) ' �C']}];
%         end
    end
    Data_T(i).Load = repmat(Data_T(i).Load,length(dT),1);
    %Add noise
    Data_T(i).Strains = [Data_T(i).Strains + wgn(size(Data_T(i).Strains,1),size(Data_T(i).Strains,2),-17.5)];
    plot(Data_T(i).Strains(20,:))
    hold on
end


%%  GENERATE THE LSTM TRUCTURE AND ORGANIZE THE DATA  %%

LSTM_Style = LSTM_Style;

Data_T = rmfield(Data_T,'Temp');
Data_T = rmfield(Data_T,'Ref_Strains');
Data_T = rmfield(Data_T,'TempCoef');
Data_T = rmfield(Data_T,'Temperature');

LSTM_S = LSTM_Struct(LSTM_Style,Data_T);
LSTM = TrValTe(LSTM_Style,LSTM_S,15,15);



%% PLOTS
%{
figure()
leg = {};
for i = 11:15
    plot(Data(i).Strains,'o-'); hold on
    leg = cat(1,leg,{[Data(i).Type,'-', Data(i).Size]});
end
legend(leg)
title('Estado Und para diferentes temperaturas')

figure()
leg = {};
for i = 11:15
    plot(Data(i).Strains-Data(end).Strains,'o-'); hold on
    leg = cat(1,leg,{[Data(i).Type,'-', Data(i).Size]});
end
legend(leg)
title('Deformaciones por la diferencia de temperatura: ref 180�C')
%}

save('Data\LSTM_Data', 'Data_T', 'LSTM')