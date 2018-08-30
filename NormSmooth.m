function SaTC3_NormSmooth(s)
%Accepts subject number as input. Conducts Normalization/Smoothing

% Composed by Anthony Resnick 6/14/2017

scriptdir = pwd;
subID = num2str(s);
cd('..')
maindir = pwd;
rawdir = [maindir, '/Raw']
%Laptop Setup. 
outputdir = [maindir, '/Preprocessed']; %Where should images be output? 
subdir = [outputdir,'/',subID,'_3D'];
inputfile = [subdir,'/',subID,'_inputs.mat'];

cd(subdir)

load(inputfile);
dname = inputs.niftidir;
defaults = spm('defaults','fmri');

cd(fullfile(subdir,'T1'));
anatomicalField = dir('y_s*.nii');
anatomicalFieldPath = {fullfile(subdir,'T1',anatomicalField.name)};


runs={'recog_1' 'recog_2' 'recog_3' 'brandrec' 'fmradapt_1' 'fmradapt_2' 'adview'};
session={};
%% Grabbing Scans
for r=1:length(runs)
    cd(fullfile(subdir,runs{r},'Non Moco'));
    funcFiles = struct2cell(dir('as0*.nii'));
    funcHeadidx = strfind(funcFiles{1,1},'_');
    funcHead = funcFiles{1}(1:funcHeadidx);
    tempsession = funcFiles(1,:)';
    tempsession = fullfile(subdir,runs{r},'Non Moco',tempsession);
    session = [session;tempsession];
end

% --------------------
%% Create Job
% --------------------

matlabbatch{1}.spm.spatial.normalise.write.subj.def = anatomicalFieldPath;
%%
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = session;
%%
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                          90 90 108];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;

matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{2}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';


%% Save Segment batch file, Run job
save(fullfile(subdir,['FuncPreProc-NormSmooth-' date '.mat']),'matlabbatch');
cd(subdir)
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

cd(scriptdir)
end


