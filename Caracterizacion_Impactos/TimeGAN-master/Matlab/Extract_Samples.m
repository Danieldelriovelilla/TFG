clear all;
close all;
clc;

Data_Path = 'C:\Users\danie\OneDrive - Universidad Politécnica de Madrid\TFG\Datos_TFG\Impactos\A380_Christian\Time_Gan\';
load([Data_Path 'generated_11.dat'])

generated = []; 
for i = 1:20; 
    simple = generated_11(i,:,:); 
    extract_impact = []; 
    for j = 1:8; 
        extract_impact = [extract_impact; simple(1:125)]; 
        simple(1:125) = [];
    end
    generated(i,:,:) = extract_impact;
end

figure()
hold on;
for i = 1:8
    plot(extract_impact(i,:))
end


%% T-SNE DATA PROCESSING
original = [];
original_labels = [];
original_num = [];
for i = 1:6
    loaded = load([Data_Path 'original_1' num2str(i) '.dat']);
    original = [original; loaded];
    for i2 = 1:size(loaded,1)
        original_labels = [original_labels; {['original_1' num2str(i)]}];
        original_num = [original_num; i];
    end
end

generated = [];
generated_labels = [];
generated_num = [];
for i = 1:6
    loaded = load([Data_Path 'generated_1' num2str(i) '.dat']);
    generated = [generated; loaded];   
    for i2 = 1:size(loaded,1)
        generated_labels = [generated_labels; {['generated_1' num2str(i)]}];
        generated_num = [generated_num; i];
    end
end
generated_num = generated_num + 6;
labels = [original_labels;generated_labels];


figure()
Y = tsne([original; generated],'Perplexity',20);    %Y = tsne([original; generated]);
gscatter(Y(:,1),Y(:,2), labels)


%% PLOT
impacts = [original; generated];
num_labels = [original_num; generated_num];
figure();
m = ['+','o','*','d','x','s','+','o','*','d','x','s'];
%m = ['+', 'o', '*','.','x','s','d','v','^','>','<','p',h','+','o','*'];

hold on
for i = 1:12
    pos = find(num_labels == i);
    plot(Y(pos(1):pos(end),1),Y(pos(1):pos(end),2),m(i),'LineWidth',2)
    leg(i) = labels(pos(1));
end
box on
legend(leg)