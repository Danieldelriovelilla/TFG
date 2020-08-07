clear all
close all
clc

Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Impactos\A380_Christian\';
load([Data_Path 'Events_Processed.mat'])

data = Processed.Data;
labels = Processed.Labels;
categ = categories(labels);

h = figure();
hold on; 
for i = 1:8; 
    plot(data{961}(i,:),'LineWidth',2); 
    leg{i} = ['PZT' num2str(i)];
end; 
title('\textbf{CELDA 72, MUESTRA 2}','Interpreter','latex')
xlabel('Time [$10^{-4}$ s]','Interpreter','latex')
ylabel('Voltage [V]','Interpreter','latex')
legend(leg,'NumColumns',2)
box on
axis([0 125 -4 4])

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'TFG_Figures\Impacto_72_2','-dpdf','-r0')


label_tsne = [];
impacts_tsne = [];
for category = 1:8%length(categ)
    pos = find(labels == categ{category});
    for i = 1:length(pos)
        impact = [];
        for i2 = 1:8
            impact = cat(2,impact,data{pos(i)}(i2,:));
        end
        impacts_tsne = cat(1,impacts_tsne,impact);
        label_tsne = cat(1,label_tsne,{['R-' categ{category}]});        
    end
end


%% TimeGAN

TimeGAN_path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Impactos\A380_Christian\Time_Gan\';

generated_impact = [];
generated_label = [];
for i = 72
    impact = load([TimeGAN_path 'generated_' num2str(i) '.dat']);
    generated_impact = cat(1,generated_impact,impact);
    for i2 = 1:size(impact,1)
        generated_label = cat(1,generated_label,{['G-' num2str(10+i)]});
    end
end


% 11, 5 y 7; 
    impact = reshape(generated_impact(7,:),125,8);
    h = figure();
    hold on; 
    for i = 1:8; 
        plot(impact(:,i),'LineWidth',2); 
        leg{i} = ['PZT' num2str(i)];
    end
    axis([0 125 -4 4])
    
title('\textbf{CELDA 11, MUESTRA SINTETICA 2}','Interpreter','latex')
xlabel('Time [$10^{-4}$ s]','Interpreter','latex')
ylabel('Voltage [V]','Interpreter','latex')
legend(leg,'NumColumns',2)
box on

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'TFG_Figures\Impacto_11_2_S','-dpdf','-r0')



%% t-sne

%generated
figure()
options = statset('MaxIter',10);
Y = tsne(generated_impact,'Algorithm','exact','Exaggeration',1500,'Standardize',true,'Options',options); 
gscatter(Y(:,1),Y(:,2),generated_label)

%{
%combination
% real
figure()
options = statset('MaxIter',100);
Y = tsne(impacts_tsne,'Algorithm','exact','Exaggeration',30,'Standardize',true,'Options',options); 
gscatter(Y(:,1),Y(:,2),label_tsne)


figure()
options = statset('MaxIter',1000);
Y = tsne([impacts_tsne; generated_impact],'Algorithm','exact','Exaggeration',30,'Standardize',true,'Options',options); 
gscatter(Y(:,1),Y(:,2),[label_tsne; generated_label])
%}
