%%   PROGRAM DESCRIPTION   %%
%{
    Extract strains forom the real test vectors stored at Excels files
    All Excel and matrix wich are used are stored at the FBG VC folder

    Plot the strains and delete the steps.
    Store the strains setting a start step which correspond to the minimim
    load that is going to be considered
%} 

clc
clear all;
close all;


%%   LOAD OR STRACT THE DATA   
tic
Excel_Folder_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\DMPA\Antonio_Articulo\Excels_Dani\Ensayos_INESSASE\FBG\Excel\';
Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\INESASSE\Real\FBG\';


if isfile([Excel_Folder_Path 'Damage_1_Real.mat'])
    
    load([Excel_Folder_Path 'Damage_1_Real.mat'])
    load([Excel_Folder_Path 'Damage_4_Real.mat'])
    load([Excel_Folder_Path 'Damage_14_Real.mat'])
    load([Excel_Folder_Path 'Undamaged_Real.mat'])

else                                        
        
    % EXTRACT EXCEL DATA AND SAVE IT

    Range = 'B147:U7500';

    %Damage 1
    Excel_Path = [Excel_Folder_Path 'Damage_1_Real.xlsx'];

    D01_01R = xlsread(Excel_Path,1,Range);
    D01_02R = xlsread(Excel_Path,2,Range);
    D01_03R = xlsread(Excel_Path,3,Range);
    D01_04R = xlsread(Excel_Path,4,Range);
    D01_05R = xlsread(Excel_Path,5,Range);
    D01_06R = xlsread(Excel_Path,6,Range);
    D01_07_1R = xlsread(Excel_Path,7,Range);
    D01_07_2R = xlsread(Excel_Path,8,Range);
    D01_07_3R = xlsread(Excel_Path,9,Range);
    D01_07_4R = xlsread(Excel_Path,10,Range);
    D01_11R = xlsread(Excel_Path,11,Range);
    D01_15R = xlsread(Excel_Path,12,Range);

    save([Excel_Folder_Path 'Damage_1_Real.mat'],'D01_01R','D01_02R',...
        'D01_03R','D01_04R','D01_05R','D01_06R','D01_07_1R','D01_07_2R',...
        'D01_07_3R','D01_07_4R','D01_11R','D01_15R')


    %Damage 4
    Excel_Path = [Excel_Folder_Path 'Damage_4_Real.xlsx'];

    D04_03R = xlsread(Excel_Path,1,Range);
    D04_06R = xlsread(Excel_Path,2,Range);
    D04_12R = xlsread(Excel_Path,3,Range);
    D04_15R = xlsread(Excel_Path,4,Range);
    D04_23R = xlsread(Excel_Path,5,Range);
    D04_31R = xlsread(Excel_Path,6,Range);


    save([Excel_Folder_Path 'Damage_4_Real.mat'],'D04_03R','D04_06R',...
        'D04_12R','D04_15R','D04_23R','D04_31R')


    %%Damage 14
    Excel_Path = [Excel_Folder_Path 'Damage_14_Real.xlsx'];

    D14_03R = xlsread(Excel_Path,1,Range);
    D14_06R = xlsread(Excel_Path,2,Range);
    D14_09R = xlsread(Excel_Path,3,Range);
    D14_12R = xlsread(Excel_Path,4,Range);
    D14_15R = xlsread(Excel_Path,5,Range);
    D14_23R = xlsread(Excel_Path,6,Range);
    D14_31R = xlsread(Excel_Path,7,Range);


    save([Excel_Folder_Path 'Damage_14_Real.mat'],'D14_03R','D14_06R',...
        'D14_09R','D14_12R','D14_15R','D14_23R','D14_31R')


    %Damage Und
    Excel_Path = [Excel_Folder_Path 'Undamaged_Real.xlsx'];

    Und_D01 = xlsread(Excel_Path,1,Range);
    Und_D04 = xlsread(Excel_Path,2,Range);


    save([Excel_Folder_Path 'Undamaged_Real.mat'],'Und_D01','Und_D04')

end


%% CREATE THE STRUCT

Data = struct('Type', {}, 'Size', {}, 'Ty_Si', {}, 'Strains', {},...
    'Jumps', {}, 'Raw_Intervals', [], 'Load', []);


%% STORE THE DIFFERENT DAMAGE LEVELS

Riv = who('-file',[Excel_Folder_Path 'Damage_1_Real.mat']);     %Rivets extracted at Damage x
Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Damage_4_Real.mat']));
Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Damage_14_Real.mat']));
Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Undamaged_Real.mat']));

for i = 1:length(Riv)
    Data(i).Type = {Riv{i}(1:3)};
    Data(i).Size = {[Riv{i}(5:6) 'R']};
    Data(i).Ty_Si = {[Riv{i}(1:3) '-' Riv{i}(5:6) 'R']};
    Data(i).Strains = eval(Riv{i});
end


%% MODIFY TEST PROBLEMS

Data(18) = [];  %D04_31R Test has less load steps --> DECICE AN ACTION
Data(15).Strains(1:750,:) = [];    %Avoid start problems at D4_12R
%------------------%

D1_names = who('-file',[Excel_Folder_Path 'Damage_1_Real.mat']);
D1_names(1:end,2) = {'D01'};

D14_names = who('-file',[Excel_Folder_Path 'Damage_14_Real.mat']);
D14_names(1:end,2) = {'D14'};

D4_names = who('-file',[Excel_Folder_Path 'Damage_4_Real.mat']);
D4_names(1:end,2) = {'D04'};
D4_names(end,:) = [];   %31R Test has less load steps --> DECICE AN ACTION

Und_names = who('-file',[Excel_Folder_Path 'Undamaged_Real.mat']);
Und_names(1:end,2) = {'Und'};

Damages = [D1_names; D14_names; D4_names; Und_names];
Cat_Dam = categorical(Damages(2,:));

for i = 1:length(Damages)
    Damages{i,3} = eval(Damages{i,1});  %     (:,1)         (:,2)     (:,3)
end                                     % Damage level  Damage type  Strains

Damages{22,3}(1:750,:) = [];    %Avoid start problems at D4_12R



%% PLOT PREPROCESSING: EXTRACT LOAD STEPS

for i = 1:length(Data)
    
    [Index_Change,s1] = ischange(Data(i).Strains(:,14),'Threshold',300);
    
    %Plot steps
    figure(i);
    hold on;
    plot(Data(i).Strains(:,14))
    plot(Index_Change*(-130))
    title(Data(i).Ty_Si)
    
    if i == 11   %Modify false steps
        Index_Change(547) = 0; Index_Change(1258) = 0; Index_Change(1605) = 0;
        Index_Change(2006) = 0; Index_Change(2392) = 0;
    elseif i == 13
        Index_Change(1787) = 0;
    %elseif i == 20
        %Index_Change(1787) = 0;
    elseif i == 25
        Index_Change(3842) = 0; Index_Change(5119) = 0;
    end
    
    plot(Index_Change*(-135))
    grid on
    hold off
    
    Jumps = find(Index_Change==1);
    
    Data(i).Jumps = [1 Jumps(1); Jumps(2) Jumps(3); Jumps(4) Jumps(5);...
        Jumps(6) Jumps(7); Jumps(8) Jumps(9); Jumps(10) Jumps(11);...
        Jumps(12) Jumps(13); Jumps(14) Jumps(15);...
        Jumps(16) Jumps(17); Jumps(18) Jumps(19);...
        Jumps(20) Jumps(21)];
    
    Safe_Increment = 20;
    for j = 1:size(Data(i).Jumps,1)
        Data(i).Jumps(j,1) = Data(i).Jumps(j,1) + Safe_Increment;
        Data(i).Jumps(j,2) = Data(i).Jumps(j,2) - Safe_Increment;
    end
    Data(i).Jumps(j,2) = Data(i).Jumps(j,2) - 25;   %Avoid a little curve at the end
    
end
close all
%{
h = figure();
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

%% PLOT DEFORMACIONES
h = figure();
for i = 1:20;
    plot(Data(1).Strains(:,i)); 
    hold on;
    %leg(i) = {num2str(i)};
end
axis([0 4763 -150 75])
xlabel('Tiempo','Interpreter','latex')
ylabel('Deformacion','Interpreter','latex')
title(['\textbf{D01-01R}'],'Interpreter','latex')
%legend(leg)

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'TFG_Figures\Sensores_FBG','-dpdf','-r0')


%%

Start_Step = 4;
f = 0;
for i = 1:length(Data)
    for j = Start_Step:length(Data(i).Jumps)
        Data(i).Raw_Intervals = cat(1, Data(i).Raw_Intervals, Data(i).Strains(Data(i).Jumps(j,1):Data(i).Jumps(j,2),:));
        for k = 1:(Data(i).Jumps(j,2)-Data(i).Jumps(j,1)+1)
            Data(i).Load = cat(1, Data(i).Load, {num2str((j-1)*10)});
        end
    end
    %Data(i).Raw_Intervals = Data(i).Raw_Intervals';
    Data(i).Jumps(1:Start_Step-1,:) = [];
    %{
    fig = figure();
    plot(Data(i).Raw_Intervals(14,:))
    grid on
    title([Data(i).Dam_State '-' Data(i).Dam_Size{:}])
    if isfile(['Figures\Promedio\Desviacion\Medidas_Tiempo\' Data(i).Dam_State '-' Data(i).Dam_Size{:} '.png'])
        f = f + 1;
        saveas(fig,['Figures\Promedio\Desviacion\Medidas_Tiempo\' Data(i).Dam_State '-' Data(i).Dam_Size{:} '-' num2str(f) '.png'])
    else
        saveas(fig,['Figures\Promedio\Desviacion\Medidas_Tiempo\' Data(i).Dam_State '-' Data(i).Dam_Size{:} '.png'])
    end
    %}
end


save([Data_Path 'Data_Raw.mat'],'Data', 'Start_Step')
toc