%%   CALCULO DE DEFORMACIONES   %%

clc;
clear all;
close all;


%%   LOAD OR STRACT THE DATA   %%   
tic
LSTM_Style = LSTM_Style;

load('Data\Data_Raw.mat')

display('Select between the next options: ')
display('    1. Perform the strain calculation with a mean')
display('    2. Extract the raw strains directly')
n = input('Enter a number: ');

switch n
    
    case 1
        
        disp('You have selected: MEAN STRAINS')
        
        
        %%  MEAN STRAINS CALCULUS  %%
        
        %-  Maximun number of element used on a mean  -%
        num = 10;
        
        %-  Perform the mean calculation and store in a LSTM form  -%
        Mean(length(Data)).Type = [];
        [Mean.Type] = deal(Data(:).Type);
        [Mean.Size] = deal(Data(:).Size);
        [Mean.Ty_Si] = deal(Data(:).Ty_Si);
        
        for n = 1:num
            for i = 1:length(Data)
                steps(1,1) = 1;
                steps(1,2) = Data(i).Jumps(1,2)-Data(i).Jumps(1,1)+1;
                for i2 = 2:length(Data(i).Jumps)
                    steps = [steps; [steps(i2-1,2)+1,...
                        steps(i2-1,2)+1+Data(i).Jumps(i2,2)-Data(i).Jumps(i2,1)]];
                end
                Mean(i).Strains = [];
                Mean(i).Load = [];
                for i2 = 1:length(steps)
                    pos = steps(i2,1):n:steps(i2,2);
                    for i3 = 1:length(pos)-1
                        Mean(i).Strains = [Mean(i).Strains;...
                            mean(Data(i).Raw_Intervals(pos(i3):pos(i3+1),:))];
                        Mean(i).Load = [Mean(i).Load;Data(i).Load(pos(i3))];
                    end
                end
            clear steps    
            end
            
            One_Mean = LSTM_Struct(LSTM_Style,Mean);
            LSTM(n) = TrValTe(LSTM_Style,One_Mean,15,15);
        end 
              
        
        %-   DEVIATION PLOTS   -%
                %{
        Mean = struct('Type', [], 'Size', [], 'Steps', [], 'Mean', [], ...
            'Dev', [], 'S_Dev', []);
        
        
        for i = 1:length(Data)
            Mean(i).Type = Data(i).Type;
            Mean(i).Size = Data(i).Size;
            Mean(i).Steps(1,1) = 1;
            Mean(i).Steps(1,2) = Data(i).Jumps(1,2)-Data(i).Jumps(1,1)+1;
            for i2 = 2:length(Data(i).Jumps)
                Mean(i).Steps = cat(1,Mean(i).Steps,[Mean(i).Steps(i2-1,2)+1,...
                    Mean(i).Steps(i2-1,2)+1+Data(i).Jumps(i2,2)-Data(i).Jumps(i2,1)]);
            end
            for j = 1:length(Data(i).Jumps)
                for i2 = 1:num
                    pos = Mean(i).Steps(j,1):i2:Mean(i).Steps(j,2);
                    for sensor = 1:20
                        Mean_Calc = [];
                        for i3 = 1:length(pos)-1
                            Mean_Calc = cat(2,Mean_Calc,...
                                mean(Data(i).Raw_Intervals(pos(i3):pos(i3+1),sensor)));
                        end
                        Mean(i).Mean{i2,j}(sensor,:) = Mean_Calc;
                        Mean(i).Dev{i2,j}(sensor,:) = std(Mean_Calc);
                    end
                    Mean(i).S_Dev(i2,j) = sum(Mean(i).Dev{i2,j}(:,1));
                end
            end
        end

        marker = ['o';'+';'*';'h';'s';'d';'v';'p'];
        f = 0;
        for i = 1:length(Mean)
            fig = figure();
            Leg = {};
            for j = 1:8
                plot(Mean(i).S_Dev(:,j),[marker(j) '-'])
                Leg{j} = num2str((j+2)*10);
                xlabel('n')
                ylabel('Sum(desviacion tipica)')
                hold on
            end
            title([Mean(i).Syze '-' Mean(i).Size{:}])
            hleg = legend(Leg);
            htitle = get(hleg,'Title');
            set(htitle,'String','Load %')
            
            if isfile(['Figures\Promedio\Desviacion\' Mean(i).Syze '-' Mean(i).Size{:} '.png'])
                f = f + 1;
                saveas(fig,['Figures\Promedio\Desviacion\' Mean(i).Syze '-' Mean(i).Size{:} '-' num2str(f) '.png'])
            else
                saveas(fig,['Figures\Promedio\Desviacion\' Mean(i).Syze '-' Mean(i).Size{:} '.png'])
            end
        end
        %}
        
        %-  SAVE RESULTS  -%
        
        save(['Data\Mean-1to' num2str(num) '_Min-Load-' num2str((Start_Step-1)*10)],...
              'LSTM','Data')
       
          
    case 2  
        
        disp('You have selected: RAW STRAINS')
        
        [Data.Strains] = deal(Data(:).Raw_Intervals);
        Data = rmfield(Data,'Jumps');
        Data = rmfield(Data,'Raw_Intervals');
        
        %No meto los dam individuales: clasificar el tamaño solo en D01,
        %D02...
        
        LSTM = LSTM_Struct(LSTM_Style,Data);
        LSTM = TrValTe(LSTM_Style,LSTM,15,15);
        

        %% SAVE RESULTS
         save(['Data\Raw_Data_Min-Load-' num2str((Start_Step-1)*10)],...
               'LSTM','Data')
              
        
    otherwise
        disp('otherwise')
        
end
toc