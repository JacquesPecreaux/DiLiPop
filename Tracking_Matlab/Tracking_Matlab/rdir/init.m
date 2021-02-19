load begining_create_fit_Sl_l_=20.mat
[mat, p] = uigetfile('*.mat','Please choose a job file to process');
histo = fullfile(p, mat);
load (histo)
disp(histo)
%load all_times.mat

%freq_fit=squeeze(histo_avg(8,1,:,:));
%power_fit=squeeze(histo_avg(8,3,:,:));
%weight_fit=1./squeeze(histo_avg(8,