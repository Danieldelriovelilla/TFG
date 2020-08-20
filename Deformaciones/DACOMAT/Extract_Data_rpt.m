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

Sensors = [S1; S2; S3; S4; S5; S6; S7; S8]; %Elements number
%Sensors = [S3; S4; S5; S6]; %Elements number


%%  PUNCTUAL LOAD  %%

Data = struct('Type', {}, 'Size', {},'Ty_Si', {}, 'Temp', {}, 'Load', {}, ...
    'Load_Strains', {},'Temperature', {}, 'TempCoef', {}, 'Temp_Strains', {}, ...
    'Strains', {});

repeat = 5*30*6;
Noise = [0:5:25];

% Load scaling
load = [0.3:0.1:1];
for i = 1:length(load)
    Load(i,1) = {num2str(load(i))}';
end


% Temperature scaling
Tr = 180;
temps = [-10:10:40];
dT = temps - Tr;
for i = 1:length(temps)
    Temperature(i,1) = {num2str(temps(i))}';
end

%Punctual load Strains
h = figure();
for i = 1:length(FileNames) 
    %Extract the information of the sensors' elements
    Element_Position = [];   
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
    
    %Calculate the temperature coefficient
    if Data(i).Temp{:} == '180'
        strains = RawData(Element_Position,2)'*4*10e2;
        Data(i).TempCoef = (strains - strains_odd)/...
            (str2num(Data(i).Temp{:}) - str2num(Data(i-1).Temp{:}));
        
        % Pure load strains
        Data(i).Load = repmat(Load,repeat,1);
        Data(i).Load_Strains = repmat(load'*strains,repeat,1);
        
        % Pure temperature strains
        for i2 = 1:length(temps)
            Data(i).Temp_Strains = [Data(i).Temp_Strains; ...
                repmat(dT(i2)*Data(i).TempCoef,repeat*8/6,1)];
            Data(i).Temperature = [Data(i).Temperature; ...
                repmat(Temperature(i2),repeat*8/6,1)];
        end
        
        % Combine the load and temperature strains
        Data(i).Strains = Data(i).Load_Strains + Data(i).Temp_Strains;
    
        % Add gausian noise
        Data(i).Strains = Data(i).Strains + ...
            wgn(size(Data(i).Strains,1),size(Data(i).Strains,2),-10);
    else
        strains = RawData(Element_Position,2)'*4*10e2;
        strains_odd = strains;
    end
    
    % Plot strains
    plot(strains)
    hold on
end

%{
    hold on;
    plot(Data(1).Strains(:,14))
    reescalados = Index_Change*(-150) + 15;
    plot(reescalados)
    axis([0 3075 -135 5])

    xlabel('Tiempo','Interpreter','latex')
    ylabel('Deformacion','Interpreter','latex')
    title(['\textbf{D01-01R: sensor 14}'],'Interpreter','latex')
    %legend(leg)

    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(h,'TFG_Figures\Saltos_FBG','-dpdf','-r0')
%}


%%  GENERATE THE LSTM TRUCTURE AND ORGANIZE THE DATA  %%

LSTM_Style = LSTM_Style;

Data = rmfield(Data,'Temp');
Data = rmfield(Data,'Load_Strains');
Data = rmfield(Data,'TempCoef');
Data = rmfield(Data,'Temp_Strains');

remove = 2:2:length(Data);
for i = 1:length(remove)
    Data_New(i) = Data(remove(i));
end

LSTM_S = LSTM_Struct(LSTM_Style,Data_New);
LSTM = TrValTe(LSTM_Style,LSTM_S,15,15);

save('C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\DACOMAT\LSTM_Data', 'LSTM')