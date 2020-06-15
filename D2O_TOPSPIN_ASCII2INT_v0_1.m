% Import spectra ascii files
clear all 
close all
files = dir('*\pdata\*\ascii-spec.txt');
files_names = dir('*\pdata\*\title');


for i = 1:size(files,1)
addpath(files(i).folder)
out{i} = dlmread(files(1).name,',', 1, 0);
% Import identifier
name{i} = fileread(files_names(i).name);
rmpath(files(i).folder) 
end

%Peak finding + integration

for i = 1:size(files,1)
mtest(:,1) = out{i}(:,4);
mtest(:,2) = out{i}(:,2);
mtest = mtest(out{i}(:,4)> 3 & out{1}(:,4)<6.5,:);
mtest = flipud(mtest);

maxint = max(mtest(:,2));
[pks,locs,w,p] = findpeaks(mtest(:,2),mtest(:,1),'MinPeakHeight',maxint*0.3);

h = figure;
hold on
findpeaks(mtest(:,2),mtest(:,1),'MinPeakHeight',maxint*0.3,'Annotate','extents');
set(gca,'XDir','reverse')
% wid = multiplication of half width
dataObjs = findobj(h,'-property','YData');
half_w = dataObjs(1).XData;
wid = 5;
left_lim = locs-half_w(1);
right_lim =half_w(2)-locs;
ind_int = mtest(:,1) > locs-(left_lim*wid) & mtest(:,1) <  locs+(right_lim*wid);
intg = sum(mtest(ind_int,2));
% end of calculation
xlim ([locs-0.1 locs+0.1])
plot(mtest(ind_int,1),zeros(size(mtest(ind_int,1),1)),'r','Linewidth',2);
legend('off')
title(sprintf('%s',name{i}))
xlabel('ppm')
ylabel('intensity')
th = sscanf(files(i).folder(end-12:end),'%[\\esr]%d\\pdata\\1');

print(sprintf('%d.png',th(end)),'-dpng')
close all 
res_int(i,1) = intg; 
res_ppm(i,1) = locs;
res_halfwidth(i,1) = w;
clear mtest th h left_lim rigth_lim

end
% 
% % Export resuts in table
names = char(name);
T = table(names,res_int,res_ppm,res_halfwidth);
T.Properties.VariableNames{'res_int'} = 'Integral';
T.Properties.VariableNames{'names'} = 'Experiment';
T.Properties.VariableNames{'res_ppm'} = 'ppm';
T.Properties.VariableNames{'res_halfwidth'} = 'peak_halfwidth';

writetable(T,'Results.xlsx')

clear all 
close all 
% End





