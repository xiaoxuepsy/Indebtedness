clear;
clc;
spm fmri

func_path = 'G:\Functional_data';

folderstruct = dir(fullfile(func_path,'SEMI*'));
FunImg_sublist = {};

NSlice = 62;
TR = 2;
dcm_file = 'G:\Raw\SEMI1101\1006-sms_bold_2mm_run1\SEMI1101-1006-sms_bold_2mm_run1-00001.dcm';
Slice0 = dicominfo(dcm_file);
SliceOrder = Slice0.Private_0019_1029;
s0 = sort(SliceOrder);
refSlice = s0(31);
VoxSize = [3 3 3];
smooth_fwh = [8 8 8];
start_image = 1; 
spm_path = 'C:\Toolbox\spm12';

    
for i = 1:length(folderstruct)
    subj{i} = folderstruct(i).name;
end;
%%
for Si = 1:length(subj)
    
    clear matlabbatch;
   
    data_f1 = [];
    data_a1 = [];
    data_r1 = [];
    data_w1 = [];
    
    data_f2 = [];
    data_a2 = [];
    data_r2 = [];
    data_w2 = [];
    
    data_f3 = [];
    data_a3 = [];
    data_r3 = [];
    data_w3 = [];

    
    run_path = fullfile(func_path,subj{Si});
    
    run_name = dir(fullfile(func_path,subj{Si},'*run1*'));
    run1_files = dir(fullfile(run_path,run_name.name,'SEMI*.nii'));
    for i = 1:length(run1_files)
        data_f1 = [data_f1;fullfile(run_path,run_name.name),'/',[run1_files(i).name],',1'];
        data_a1 = [data_a1;fullfile(run_path,run_name.name),'/a',[run1_files(i).name],',1'];
        data_r1 = [data_r1;fullfile(run_path,run_name.name),'/ra',[run1_files(i).name],',1'];
        data_w1 = [data_w1;fullfile(run_path,run_name.name),'/wra',[run1_files(i).name],',1'];
    end;
    
    run_name = dir(fullfile(func_path,subj{Si},'*run2*'));
    run2_files = dir(fullfile(run_path,run_name.name,'SEMI*.nii'));
    for i = 1:length(run2_files)
        data_f2 = [data_f2;fullfile(run_path,run_name.name),'/',[run2_files(i).name],',1'];
        data_a2 = [data_a2;fullfile(run_path,run_name.name),'/a',[run2_files(i).name],',1'];
        data_r2 = [data_r2;fullfile(run_path,run_name.name),'/ra',[run2_files(i).name],',1'];
        data_w2 = [data_w2;fullfile(run_path,run_name.name),'/wra',[run2_files(i).name],',1'];
    end;
   
    run_name = dir(fullfile(func_path,subj{Si},'*run3*'));
    run3_files = dir(fullfile(run_path,run_name.name,'SEMI*.nii'));
    for i = 1:length(run3_files)
        data_f3 = [data_f3;fullfile(run_path,run_name.name),'/',[run3_files(i).name],',1'];
        data_a3 = [data_a3;fullfile(run_path,run_name.name),'/a',[run3_files(i).name],',1'];
        data_r3 = [data_r3;fullfile(run_path,run_name.name),'/ra',[run3_files(i).name],',1'];
        data_w3 = [data_w3;fullfile(run_path,run_name.name),'/wra',[run3_files(i).name],',1'];
    end;
    
 
        data_a = [];
        data_r = [];
        data_w = [];

      for runi = 1:3
        data_a = [data_a;cellstr(eval(strcat('data_a',num2str(runi))))];
        data_r = [data_r;cellstr(eval(strcat('data_r',num2str(runi))))];
        data_w = [data_w;cellstr(eval(strcat('data_w',num2str(runi))))];
      end

    %_______SLICE TIMING_______

    matlabbatch{1}.spm.temporal.st.scans = {cellstr(data_f1) cellstr(data_f2) cellstr(data_f3)}';
    
    matlabbatch{1}.spm.temporal.st.nslices = NSlice;
    matlabbatch{1}.spm.temporal.st.tr = TR;
    matlabbatch{1}.spm.temporal.st.ta = TR*(NSlice-1)/NSlice;
    matlabbatch{1}.spm.temporal.st.so = SliceOrder;
    matlabbatch{1}.spm.temporal.st.refslice = refSlice;
    matlabbatch{1}.spm.temporal.st.prefix = 'a';

    spm_jobman('run',matlabbatch)
    
    %_______REALIGN: Estimation and Reslice_______

    clear matlabbatch;   

    matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(data_a1) cellstr(data_a2) cellstr(data_a3)}';
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1; % realign to mean
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';    
    
    spm_jobman('run',matlabbatch)
    
    %_____________________NORMALIZE: Estimate and Write_____________________
   
    clear matlabbatch;
    
    run_name = dir(fullfile(func_path,subj{Si},'*run1*'));
    run1_path = fullfile(run_path,run_name.name);
    
    sour_file = [run1_path,'/meana',[run1_files(start_image).name],',1'];
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = cellstr(sour_file);
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = cellstr(data_r);
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;

    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(spm_path,'tpm','TPM.nii')};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                                 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = VoxSize;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
    
    spm_jobman('run',matlabbatch)
    
	%_____________________SMOOTH_____________________

    clear matlabbatch;
    
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(data_w);
    matlabbatch{1}.spm.spatial.smooth.fwhm = smooth_fwh;
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';

	spm_jobman('run',matlabbatch)

end