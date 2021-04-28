clear all 
close all 

load('Res_inten.mat')

% Convert time to hours and sort cell by it
time_tab = res_all(:,4);
time_f = sort(time_tab);

for i = 1:size(res_all,1)
t11=datevec(datenum(res_all(i,4)));
t22=datevec(datenum(time_f(1)));
time_dif = etime(t11,t22);
time_h = time_dif/3600;
res_all{i,5} = time_h;
end
out = sortrows(res_all,5);

% find indices for first and last spectra
fid_fil = dir('*\fid');
a = cellstr(vertcat(fid_fil.date));
idx = strcmp(out{1,4},a); %idx for fid_fil
search_string = sprintf('%s\\pdata\\1', fid_fil(idx).folder); %search string

%load spectreas and substract them 
files = dir('*\pdata\*\ascii-spec.txt');

b = struct2cell(files);
idx_2 = cellfun(@(c) ischar(c) && strcmp(c, search_string), b);
idx = idx_2(2,:)';




for i = 1:size(files,1)
addpath(files(i).folder)
pout{i} = dlmread(files(i).name,',', 1, 0);
% Import identifier
name{i} = fileread('title');
rmpath(files(i).folder) 
end

%first spectra
mtest(:,1) = pout{idx}(:,4);
mtest(:,2) = pout{idx}(:,2);
% mtest2 = mtest(pout{idx}(:,4) > 0 & pout{idx}(:,4)<3.4,:);
% mtest = mtest(pout{idx}(:,4) > 5 & pout{idx}(:,4)<11,:);
mtest = flipud(mtest);
% mtest2 = flipud(mtest2);
x = mtest(:,1);
y = mtest(:,2);
% x = [mtest2(:,1); mtest(:,1)];
% y = [mtest2(:,2); mtest(:,2)];
% noise estimate
nos = mtest(mtest(:,1)>10.5,2);
nos_f = abs(min(nos)-max(nos));
clear mtest mtest2

pr_name ='PCA_spectra';
mkdir(pr_name)
addpath(pr_name)

for i = 1:size(files,1)
idx_last = strcmp(out{i,4},a); %idx for fid_fil
search_string = sprintf('%s\\pdata\\1', fid_fil(idx_last).folder); %search string
idx_2 = cellfun(@(c) ischar(c) && strcmp(c, search_string), b);
idx_last = idx_2(2,:)';

%last spectra
mtest(:,1) = pout{idx_last}(:,4);
mtest(:,2) = pout{idx_last}(:,2);
mtest = flipud(mtest);
x2 = mtest(:,1);
y2 = mtest(:,2);
% noise estimate
nos = mtest(mtest(:,1)>10.5,2);
nos_l = abs(min(nos)-max(nos));


%difference spectra
if size(y,1) == size(y2,1)
y_diff = y2-y;
nos = y_diff(x>10.5);
else 
    com_len = min([size(y,1) size(y2,1)]);
    y_diff = y2(1:com_len) - y(1:com_len);
    ind_err = x>10.5;
    nos = y_diff(ind_err(1:com_len));
end
nos_d = abs(min(nos)-max(nos));
y_diff(y_diff<0) = 0;
spectras{i} = y_diff;
clear mtest

figure('units','normalized','outerposition',[0 0 0.7 0.8],'visible','off');
subplot(1, 2, 1);
plot(x,y_diff,'LineWidth',2)
set(gca,'XDir','reverse')
xlim([5 Inf])
xlabel('ppm')
ylabel('intensity')
set(gca,'Fontsize',14)

subplot(1, 2, 2);
plot(x,y_diff,'LineWidth',2)
set(gca,'XDir','reverse')
xlim([-Inf 3.45])
xlabel('ppm')
ylabel('intensity')
set(gca,'Fontsize',14)

to_scan = files(idx_last).folder(end-12:end);
ind = regexp(to_scan,'\\');
th = sscanf(to_scan(ind(1):ind(2)),'%*[^0123456789]%d');
sgtitle(sprintf('%s %d',name{idx_last},th))

print(sprintf('%s/%s/%d PCA full spectra.png',pwd,pr_name,th(1)),'-dpng')

end
% 
% [pks,locs] = findpeaks(y_diff,x,'MinPeakProminence',nos_d);
rmpath(pr_name)
time = vertcat(out{:,5});
save('PCA_spectra.mat','x','spectras','time')


