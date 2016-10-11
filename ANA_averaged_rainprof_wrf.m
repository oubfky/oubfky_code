% ANA_averaged_rainprof_wrf
% cd C:\Users\pingl\Dropbox\TCRM\OUTPUTANALYSIS


% clear
% clc
% close all

function ANA_averaged_rainprof_wrf(casestring)


%casestring = 'KETCRM50_s20_G_Cd5';
savedir = ['../OUTPUT/',casestring,'.mat'];
savefigdir = ['./',casestring,'/'];
mkdir(savefigdir)
load(savedir)


if isempty(hname) == 0
wrfdatadir = ['../../WRFDATA/',hname,'_profile/'];

elseif isempty(hname) == 1 && str2num(casestring(7:8))==49 %Irene
    wrfdatadir = '../../WRFDATA/Irene2011_profile/';
elseif isempty(hname) == 1 && str2num(casestring(7:8))==50 %Isabel
    wrfdatadir = '../../WRFDATA/Isabel2003_profile/';
end

%
load([wrfdatadir,'./900mb/','Rm.mat'])
load([wrfdatadir,'./900mb/','rr.mat'])
load([wrfdatadir,'Rainprof_wrf_ar'])
size3 = max(size(Rm));

%% do the averaging
% get rainfall profile
Rainprof_output = zeros(size3,max(size(rr)));
for i = 3:size3-2
    xrain = Rain(:,:,i); 
    xrain(find(xrain < -1000)) = 0;
    xrain(find(xrain > 1000))= 0;
    xrain(isnan(xrain))= 0;
    [a1,b1,c1] = radprof(rfull_SAVE(:,:,i),xrain,10); 
    a1(isnan(a1)) =0;
    b1(isnan(b1)) =0;
    x = interp1(a1(1:250),b1(1:250),rr,'linear');
    Rainprof_output(i,:) = x;
end
save([savefigdir,'Rainprof_output.mat'],'Rainprof_output')

% rescale and average
rr_rescaled = .1:0.01:3;
[Rainprof_output_rescaled,Rainprof_output_ar] = rescale_and_average_fn(Rainprof_output, rr, Rm, rr_rescaled, 13,30);
save([savefigdir,'Rainprof_output_rescaled.mat'],'Rainprof_output_rescaled')
save([savefigdir,'Rainprof_output_ar.mat'],'Rainprof_output_ar')

%% plot

 figure(1)
    set(gcf, 'units', 'centimeters');
    set(gcf, 'position',[5 5 10 10]);
    myfontsize =12;    
    set(gca,'Fontsize',myfontsize)
    set(gca, 'units', 'centimeters');
    set(gca, 'position',[1.5 2 8 6]);
    
    plot(rr_rescaled,Rainprof_output_ar,'-b',rr_rescaled,Rainprof_wrf_ar,'-k','LineWidth',2)
    
    legend('TCRM','WRF')
    %set(gca,'XLim',[0 600])
    %set(gca,'YLim',[-0.07,+0.3])
    xlabel('r/Rm','fontsize', myfontsize)
    ylabel('Rainrate mm/h','fontsize', myfontsize)
    title(sprintf('%s',casestring), 'Interpreter', 'none'); 
    
    set(gcf,'PaperPositionMode', 'auto');
    print(1,'-dtiff', '-r600',[savefigdir,'ANA_averaged_rainprof_wrf','.tiff'])
    close

