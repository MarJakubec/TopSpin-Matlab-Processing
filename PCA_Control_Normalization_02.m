clear all 
close all
%load control - needs to be named Control.mat
load('Control.mat')
spectras_con = spectras; 
time_con = time; 
x_con = x;
x2 = x(x<11);

files = dir('*.mat');
mkdir('PCA_out')
addpath('PCA_out')

for i =1:size(files,1);
load(files(i).name)
name = files(i).name(1:end-4);
mkdir(name)
addpath(name)
for j = 1:size(spectras,2)
% diff = size(spectras{j},1)-size(spectras_con{j},1);
y = spectras{j}(x<11) - spectras_con{j}(x<11);
y(y<0) = 0;
nor_spectra{j} = y;

nos = y(x2>10.5);
nos_d = abs(min(nos)-max(nos));

figure('units','normalized','outerposition',[0 0 0.7 0.8],'visible','off');
subplot(1, 2, 1);
plot(x2,y,'LineWidth',2)
set(gca,'XDir','reverse')
xlim([5 Inf])
xlabel('ppm')
ylabel('intensity')
set(gca,'Fontsize',14)

subplot(1, 2, 2);
plot(x2,y,'LineWidth',2)
set(gca,'XDir','reverse')
xlim([-Inf 3.45])
xlabel('ppm')
ylabel('intensity')
set(gca,'Fontsize',14)

sgtitle(sprintf('%s %d',name,j))
% [pks,locs] = findpeaks(y,x(1:end-diff),'MinPeakProminence',nos_d);
y_time{j} = y;

print(sprintf('%s/%s/%d %s.png',pwd,name,j,name),'-dpng')
close all 
end
rmpath(name)
save(sprintf('%s/PCA_out/%s_PCA_norm.mat',pwd,name),'y_time','x','x2',...
    'time_con')
end
rmpath('PCA_out')