%%   PROGRAM DESCRIPTION   %%
%{
    Extract strains forom the FEM excel.
    Load the data on a structure.
%} 

clc;
clear all;
close all;


%%   LOAD OR STRACT THE DATA   

Excel_Folder_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\DMPA\Antonio_Articulo\Excels_Dani\FEM\FBG\Excel\';
Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Deformaciones\INESASSE\FEM\FBG';

if isfile([Data_Path '\Data_Raw.mat'])
     
    %-  LOAD .mat WITH INFO  -%

    load([Data_Path '\Data_Raw.mat'])
     
else
    
    %-  EXTRACT EXCEL DATA AND SAVE IT  -%
    
    Excel_Path = [Excel_Folder_Path 'FBGs.xlsx'];
    
    %Damage 1    
    D01 = xlsread(Excel_Path,2);
    D01_01R = D01(8:23,2:21);
    D01_02R = D01(37:52,2:21);
    D01_03R = D01(62:77,2:21);
    D01_04R = D01(87:102,2:21);
    D01_05R = D01(112:127,2:21);
    D01_06R = D01(137:152,2:21);
    D01_07R = D01(162:177,2:21);
    D01_11R = D01(187:202,2:21);
    D01_15R = D01(212:227,2:21);

    save([Excel_Folder_Path 'Damage_01_FEM.mat'],'D01_01R','D01_02R',...
        'D01_03R','D01_04R','D01_05R','D01_06R','D01_07R','D01_11R','D01_15R')

    %Damage 4   
    D02 = xlsread(Excel_Path,6);
    D02_03R = D02(14:29,2:21);
    D02_06R = D02(36:51,2:21);
    D02_09R = D02(58:73,2:21);
    D02_11R = D02(80:95,2:21);

    save([Excel_Folder_Path 'Damage_02_FEM.mat'],'D02_03R','D02_06R',...
        'D02_09R','D02_11R') 
    
    %Damage 4   
    D04 = xlsread(Excel_Path,4);
    D04_03R = D04(22:37,2:21);
    D04_06R = D04(44:59,2:21);
    D04_12R = D04(66:81,2:21);
    D04_15R = D04(88:103,2:21);
    D04_23R = D04(110:125,2:21);
    D04_31R = D04(132:147,2:21);

    save([Excel_Folder_Path 'Damage_04_FEM.mat'],'D04_03R','D04_06R',...
        'D04_12R','D04_15R','D04_23R','D04_31R')

    %%Damage 14
    D14 = xlsread(Excel_Path,3);
    D14_03R = D14(15:30,2:21);
    D14_06R = D14(37:52,2:21);
    D14_09R = D14(59:74,2:21);
    D14_12R = D14(81:96,2:21);
    D14_15R = D14(103:118,2:21);
    D14_23R = D14(125:140,2:21);
    D14_31R = D14(147:162,2:21);

    save([Excel_Folder_Path 'Damage_14_FEM.mat'],'D14_03R','D14_06R',...
        'D14_09R','D14_12R','D14_15R','D14_23R','D14_31R') 

    %Damage Und
    Und = xlsread(Excel_Path,1);
    Und_D01 = Und(23:38,2:21);
    Und_D02 = Und(44:59,2:21);
    Und_D04 = Und(65:80,2:21);
    
    save([Excel_Folder_Path 'Undamaged_FEM.mat'],'Und_D01','Und_D02','Und_D04')
      
        
    %-  CREATE THE STRUCT  -%
    
    Data = struct('Type', {}, 'Size', {}, 'Ty_Si', {}, 'Strains', {},...
        'Load', {});
    
    
    %-  STORE THE DIFFERENT DAMAGE LEVELS  -%
    loads = [1:0.2:4]';
    for i = 1:length(loads)
        Load(i,1) = {num2str(loads(i))}';
    end
    
    Riv = who('-file',[Excel_Folder_Path 'Damage_01_FEM.mat']);     %Rivets extracted at Damage x
    %Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Damage_02_FEM.mat']));
    Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Damage_04_FEM.mat']));
    Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Damage_14_FEM.mat'])); 
    Riv = cat(1,Riv,who('-file',[Excel_Folder_Path 'Undamaged_FEM.mat']));

    repeat = 150;
    for i = 1:length(Riv)
        Data(i).Type = {Riv{i}(1:3)};
        Data(i).Size = {Riv{i}(5:end)};  
        Data(i).Ty_Si = {[Riv{i}(1:3) '-' Riv{i}(5:6) 'R']};
        strains = eval(Riv{i});
        for i2 = 2:2:length(loads)  %Select the same loads than the REAL
            Data(i).Strains = [Data(i).Strains; repmat(strains(i2,:),repeat,1)...
                + wgn(repeat,20,-9)];
            for j2 = 1:repeat
                Data(i).Load = [Data(i).Load; Load(i2)];
            end
        end
    end
    
    %-  SAVE DATA  -%
    
    save([Data_Path '\Data_Raw.mat'],'Data')
 
end


%%  GENERATE THE LSTM TRUCTURE AND ORGANIZE THE DATA  %%

LSTM_Style = LSTM_Style;

LSTM = LSTM_Struct(LSTM_Style,Data);
LSTM = TrValTe(LSTM_Style,LSTM,15,15);

save([Data_Path '\LSTM_FEM_Data'],'LSTM','Data')