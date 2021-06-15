clear
clc
spm fmri

FolderPath = 'G:\Functional_data';
OutputPath = 'G:\Analysis\First_level_communal_concern_parametric';

cd('G:\Batch\SPM12');

onset_SPM_reciprocity_cost_2levels_53subs

NSlice = 62;
refSlice = 31;
TR = 2.0;
SubList = dir(fullfile(FolderPath,'SEMI*'));
CondList = {'Outcome_all_nomiss' 'Allocation' 'info_possible' 'info_impossible' 'E2'  'E2_Allo_miss' 'Outcome_miss'};  %% conresponding to onset condition
Parametric_under_condition = { 'PCare' };

Nuisance = {};% irrelevant event , filler event   'errors'

% contrast name
cname = { 'Outcome_reciprocity_para'};
ctype = { 'T'};
simple_cons = [ 0 0 0 0 0 0 0];
para_cons = [1 ];



for nsub = 1:length(SubList)
   
    s = regexp(SubList(nsub).name,'_','split');
    substr =  regexp(s(1),'I','split');
    subnum = substr{1,1}{2};
    SubList(nsub).name
    SubOutput = fullfile(OutputPath,SubList(nsub).name);
    if ~exist(SubOutput,'dir')
        mkdir(SubOutput);
    end
    
    
    for c= 1:length(cname)
        contrast_dir{c} = fullfile(SubOutput,['contrast',num2str(c),'_',char(cname{c})]);
        if ~exist(contrast_dir{c})
            mkdir(contrast_dir{c});
        end
    end
    
    Checkfolder = fullfile(SubOutput,'ChkMsg2EstimateDone');

    RunList = dir(fullfile(FolderPath,SubList(nsub).name,'*run*'));
    
    clear matlabbatch;
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {SubOutput};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';  %'secs'
    
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = NSlice;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refSlice;
    
    for nrun = 1:length(RunList)
        
        clear Files FileList FilePath;
     
        FilePath = fullfile(FolderPath,SubList(nsub).name,RunList(nrun).name);
        FileList = dir(fullfile(FilePath,'swra*.nii'));
        
       
        for nfile = 1:length(FileList)
            Files(nfile) = {fullfile(FilePath,FileList(nfile).name)};
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).scans = cellstr(Files)';
        
       
        runnum = nrun;
        cond_num = length(CondList);

        for ncond = 1:cond_num
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).name = CondList{ncond};
            %%%%--------------Onset------------
            if ncond == 2
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = [eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_Allo_possible_onset'])/2  eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_Allo_impossible_onset'])/2];
            elseif ncond == 5
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = [eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_E2_possible_onset'])/2  eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_E2_impossible_onset'])/2];
            elseif ncond == 7
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = [eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_Outcome_miss_onset'])/2 miss_plus];
            elseif ncond == 6
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = [eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_E2_miss_onset'])/2  eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_Allo_miss_onset'])/2 ];
            else
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_' CondList{ncond} '_onset'])/2;
            end    
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).tmod = 0;
            %%%%--------------Duration------------
            if ncond == 1 || ncond == 7
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = 5/2;
            elseif ncond == 2
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = [eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_Allo_possible_duration'])/2  eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_Allo_impossible_duration'])/2];
            elseif ncond == 3 || ncond == 4
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = 4/2;
            elseif ncond == 5
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = [eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_E2_possible_duration'])/2  eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_E2_impossible_duration'])/2];
            elseif ncond == 6
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = 8/2;
            end
            %%%%%--------------Parametric modulator------------
            if isempty(Parametric_under_condition)
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod = struct('name', {}, 'param', {}, 'poly', {});
            else
                
                if ncond == 1
                    for p_c = 1:length(Parametric_under_condition)
                        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod(p_c).name = char(Parametric_under_condition{p_c});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod(p_c).param = eval([sprintf('sub%s',subnum) '_' sprintf('run%d',runnum) '_' Parametric_under_condition{p_c}]);
                        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod(p_c).poly = 1;
                    end
                    matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).orth = 1;
                
                else
                    matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod = struct('name', {}, 'param', {}, 'poly', {});
                    matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).orth = 1;
                end
            end
        end
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).regress = struct('name', {}, 'val', {});
        MultiReg = dir(fullfile(FilePath,'rp_a*.txt'));
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).multi_reg = {fullfile(FilePath,MultiReg.name)};
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).hpf = 128;
        
        
    end
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; 
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    if ~exist(Checkfolder,'dir')
        spm_jobman('run',matlabbatch);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save design matrix %%%%%%%%%%%%%%%%%%%%%
    clear matlabbatch;
    cd(SubOutput);
    matlabbatch{1}.spm.util.print.fname = 'DsgnMatrix';
    matlabbatch{1}.spm.util.print.opts.opt = {'-dpsc2'; '-append'}';
    matlabbatch{1}.spm.util.print.opts.append = true;
    matlabbatch{1}.spm.util.print.opts.ext = '.ps';
    spm_jobman('run',matlabbatch);
    save(fullfile(SubOutput,sprintf('CntrP.mat')));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% estimate model %%%%%%%%%%%%%%%%%%%%%
    
    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(SubOutput,'SPM.mat')};
    spm_jobman('run',matlabbatch);
    mkdir(Checkfolder);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% define contrasts%%%%%%%%%%%%%%%%%%%%
    Checkfolder = fullfile(SubOutput,'ChkMsg2ContrastDone');
    if exist(Checkfolder,'dir')
    else
        SPMest=load(fullfile(SubOutput,'SPM.mat'));
        SPMest=SPMest.SPM;
        SPMest.xCon = [];
        headmotion_constant = [0 0 0 0 0 0];
        for c= 1:length(cname)
            cons = [];
            
            for r = 1:length(RunList)
                
                combined_cons = [];
                run_cons = [];
                
                r_in = r;

                for s_c = 1:length(simple_cons(c,:))
                    if s_c ==1
                        combined_cons = [combined_cons simple_cons(c,s_c)  para_cons(c,:)  ];  
                    else
                        combined_cons = [combined_cons simple_cons(c,s_c)  ] ; 
                    end
                end
                
                run_cons = [combined_cons  headmotion_constant];
                
                cons = [cons run_cons];
            end
            
            cons = [cons zeros(1,length(RunList))];

            contrast(c).cname = char(cname(c));
            contrast(c).ctype = char(ctype(c));
           
            contrast(c).cons = cons';
            
            if isempty(SPMest.xCon)
                SPMest.xCon = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
            else
                SPMest.xCon (end+1) = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
            end

            dlmwrite(fullfile(SubOutput,[SubList(nsub).name,'_contrast',num2str(c),'.txt']), cons','delimiter','\t');
        end
        spm_contrasts(SPMest);
        save(fullfile(SubOutput,[SubList(nsub).name,'_','1stLevel_contrast.mat']),'contrast');
        
        
        %% copy contrast files
        for c= 1:length(cname)
            sourcefile = ['con_',strrep(num2str(c+100000000),'10000','')];
            copyfile(fullfile(SubOutput,[sourcefile,'.nii']),fullfile(contrast_dir{c},[SubList(nsub).name,'_',sourcefile,'.nii']));
        end
       
        mkdir(Checkfolder);
    end
end