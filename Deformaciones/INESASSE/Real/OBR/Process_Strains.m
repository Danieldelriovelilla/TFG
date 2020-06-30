%% PROCESS OBR STRAINS AND GENERATE THE PYTHON DATA %%

clc
clear all
close all


%% PARAMETERS

N_repeticiones = 100;


%% LOAD DATA STRUCT

Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\INESASSE\Real\OBR\';

load([Data_Path 'OBR_INESASSE.mat'])


%% RENAME THINGS

old = fieldnames(Data);
new = old;
new{1} = 'Type';
new{2} = 'Ty_Si';
Data = cell2struct(struct2cell(Data), new);

for i = 1:8
    load(i,1) = {num2str(Data(1).Load(i))};
end

for i = 1:length(Data)
    Data(i).Load = load;
end

for i = 5:8;
    Data(i).Strains(5,:) = [];
    Data(i).Load(5) = [];
end
    Data(18).Strains(5,:) = [];
    Data(6) = [];

    %{
for j = 1:length(Data)
    h = figure();
    for i = 1:size(Data(j).Strains,1)
        plot(Data(j).Strains(i,:))
        hold on
    end
    axis([0 1500 -315 150])
    xlabel('Longitud','Interpreter','latex')
    ylabel('Deformacion','Interpreter','latex')
    title([Data(j).Ty_Si{:}],'Interpreter','latex')
    %legend(leg)
    %{
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(h,['OBR_Figures/', Data(j).Dam_Size{:}],'-dpdf','-r0')
    %saveas(gcf, ['OBR_Figures/' Data(j).Dam_Size{:} '.png'])
    %}
end
    %}

noise = wgn(1500,1,-6); 
h = figure();
histogram(noise,18)


%% PLOT DAMAGES
tests = [17,2,6,9,13];
h = figure();
box on;
hold on; 
for i = 1:length(tests);
    plot(Data(tests(i)).Strains(end,:));
    leg(i) = Data(tests(i)).Ty_Si; 
end; 
legend(leg,'Interpreter','latex');
axis([0 1500 -320 150])
xlabel('Longitud','Interpreter','latex')
ylabel('Deformacion','Interpreter','latex')
title('\textbf{Carga: 4 kN}','Interpreter','latex')    
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['OBR_Figures/OBR_damages'],'-dpdf','-r0')

tests = [2,6,9,13];
h = figure();
box on;
hold on; 
for i = 1:length(tests);
    plot(Data(tests(i)).Strains(end,:)-Data(17).Strains(end,:));
    leg(i) = Data(tests(i)).Ty_Si; 
end; 
legend(leg,'Interpreter','latex');
%axis([0 1500 -60 50])
xlabel('Longitud','Interpreter','latex')
ylabel('Deformacion','Interpreter','latex')
title('\textbf{Carga: 4 kN}','Interpreter','latex')    
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,['OBR_Figures/OBR_dif'],'-dpdf','-r0')

%% GRNERATE MORE SAMPLES

for i = 1:length(Data)
    for i2 = 1:N_repeticiones
        Data(i).Noise = cat(1,Data(i).Noise,...
            Data(i).Strains+wgn(size(Data(i).Strains,1),size(Data(i).Strains,2),-5));
        Data(i).Noise_Load = cat(1,Data(i).Noise_Load,Data(i).Load);
    end
end

for i = 16:18
    Data(i).Ty_Si = {'Und'};
end


%% DATA RESHAPE
Data = rmfield(Data,{'Strains','Load'});

old = fieldnames(Data);
new = old;
new{3} = 'Strains';
new{4} = 'Load';
Data = cell2struct(struct2cell(Data), new);

LSTM_Style = LSTM_Style;

LSTM = LSTM_Struct(LSTM_Style,Data);
LSTM = TrValTe(LSTM_Style,LSTM,15,15);


%% SAVE DATA

save([Data_Path 'LSTM_Struct.mat'], 'LSTM')