clear all 
close all 


t = readtable('Results EDTA Complex.xlsx');
samples = {'Triton';
    'Blank';
    'LTX';
    'KP 76';
    'RAR'};
batch = {'Batch 1';
    'Batch 2';
    'Batch 3'};

time = {' 0.5 min'; 
    ' 5 min';
    ' 15 min';
    ' 30 min';
    ' 60 min';
    ' 90 min';
    ' 120 min';
    ' 180 min';
    ' 240 min';
    ' 300 min';
    ' 360 min'};
for i = 1:size(samples,1)
list_fin = regexp(t.Experiment,samples{i});
ind = ~cellfun(@isempty,list_fin);
res = t(ind,:);
for j = 1:size(batch,1)
list_fin = regexp(res.Experiment,batch{j});
ind = ~cellfun(@isempty,list_fin);
res2 = res(ind,:);
for k = 1:size(time,1)
list_fin = regexp(res2.Experiment,time{k});
ind = ~cellfun(@isempty,list_fin);
res3 = res2(ind,:);
sor_res{i,j}(k,1) = res3.IntegralEDTA_Ca;
sor_res{i,j}(k,2) = res3.IntegralEDTA_Mg;
end
end
end

% Max values
list_fin = regexp(t.Experiment,'OVERNIGHT');
ind = cellfun(@isempty,list_fin);
res_m = t(ind,:);
m_int(1) = max(res_m.IntegralEDTA_Ca);
m_int(2) = max(res_m.IntegralEDTA_Mg);


%Plottting 
marker = ['o'
'+'	
'*'	
'.'	
'x'	
'_'	
'|'];
col = [	0, 0.4470, 0.7410;
        0.8500, 0.3250, 0.0980;
          	0.9290, 0.6940, 0.1250;
          	0.4940, 0.1840, 0.5560;
          	0.4660, 0.6740, 0.1880;	          
          	0.3010, 0.7450, 0.9330;
          	0.6350, 0.0780, 0.1840]; 

time = [0.5 5 15 30 60 90 120 180 240 300 360]';
ions = {'EDTA-Ca Complex';
    'EDTA-Mg Complex'};
for i = 1:size(sor_res,1)
for j = 1:size(ions,1)
h = figure('units','normalized','outerposition',[0 0 0.7 0.8],'visible','off');
hold on
for k = 1:size(sor_res,2)
plot(time, sor_res{i,k}(:,j),'LineWidth',1,'Color',col(k,:))
s = scatter(time,sor_res{i,k}(:,j),36,col(k,:),marker(k));
s.LineWidth = 2;
end
set(gca,'Fontsize',16)
grid on
xlabel('time [min]')
ylabel('integral') 
title(sprintf('%s %s',samples{i}, ions{j}))
f=get(gca,'Children');
legend([f(5),f(3),f(1)],batch)
print(sprintf('%s %s.png',samples{i}, ions{j}),'-dpng')
% ylim([0 m_int(j)*1.2])
end
end
% Cumulative plot

for i = 1:size(sor_res,1)
for j = 1:size(ions,1)
h = figure('units','normalized','outerposition',[0 0 0.7 0.8],'visible','off');
hold on
for k = 1:size(sor_res,2)
sor_cul{i,k}(:,j) = cumsum(sor_res{i,k}(:,j));
plot(time, sor_cul{i,k}(:,j),'LineWidth',1,'Color',col(k,:))
s = scatter(time,sor_cul{i,k}(:,j),36,col(k,:),marker(k));
s.LineWidth = 2;
end
set(gca,'Fontsize',16)
grid on
xlabel('time [min]')
ylabel('integral') 
title(sprintf('Cumulative %s %s',samples{i}, ions{j}))
f=get(gca,'Children');
legend([f(5),f(3),f(1)],batch)
print(sprintf('Cumulative %s %s.png',samples{i}, ions{j}),'-dpng')
% ylim([0 m_int(j)*1.2])
end
end

%Overview plot
for i = 1:size(sor_res,1)
for j = 1:size(ions,1)
res_aver{i,j} = mean([sor_cul{i,1}(:,j) sor_cul{i,2}(:,j) sor_cul{i,3}(:,j)],2);
res_std{i,j} = std([sor_cul{i,1}(:,j) sor_cul{i,2}(:,j) sor_cul{i,3}(:,j)],0,2);  
end
end

for j = 1:size(ions,1)
h = figure('units','normalized','outerposition',[0 0 0.7 0.8],'visible','on');
hold on
% set(gca, 'YScale', 'log')

for i = 1:size(sor_res,1)
errorbar(time,res_aver{i,j}(:,1),res_std{i,j}(:,1)/5,'o','Color',col(i,:))
plot(time, res_aver{i,j}(:,1),'LineWidth',1,'Color',col(i,:))
end

set(gca,'Fontsize',16)
grid on
xlabel('time [min]')
ylabel('integral') 
title(sprintf('DMPC:PG %s',ions{j}))
f=get(gca,'Children');
% legend(samples)
legend([f(10) f(8) f(6),f(4),f(2)],samples)
% ylim([0 5E7])
ylim([-Inf Inf])
print(sprintf('DMPC PG %s .png', ions{j}),'-dpng')
% ylim([0 m_int(j)*1.2])
ylim([-Inf 7E7])
print(sprintf('DMPC PG Zoom %s .png', ions{j}),'-dpng')
close all 
end



