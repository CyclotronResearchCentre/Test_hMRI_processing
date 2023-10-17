%% Main function to generate tests
function tests = spm_exampleTest
    tests = functiontests(localfunctions);
end

function testFunctionPREAMBLE(testCase)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PREAMBLE: DUMMY SCANS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = cellstr(testCase.TestData.data_path);
    matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'dummy';

    matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.files = cellstr(testCase.TestData.f(1:12,:));
    matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = cellstr(fullfile(testCase.TestData.data_path,'dummy'));

    spm_jobman('run',matlabbatch);
end
function testFunctionSPACIAL(testCase)
    % Realign
    %--------------------------------------------------------------------------
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(testCase.TestData.f)};
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];

    % Coregister
    %--------------------------------------------------------------------------
    matlabbatch{2}.spm.spatial.coreg.estimate.ref    = cellstr(spm_file(testCase.TestData.f(1,:),'prefix','mean'));
    matlabbatch{2}.spm.spatial.coreg.estimate.source = cellstr(testCase.TestData.a);

    % Segment
    %--------------------------------------------------------------------------
    matlabbatch{3}.spm.spatial.preproc.channel.vols  = cellstr(testCase.TestData.a);
    matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{3}.spm.spatial.preproc.warp.write    = [0 1];

    % Normalise: Write
    %--------------------------------------------------------------------------
    matlabbatch{4}.spm.spatial.normalise.write.subj.def      = cellstr(spm_file(testCase.TestData.a,'prefix','y_','ext','nii'));
    matlabbatch{4}.spm.spatial.normalise.write.subj.resample = cellstr(testCase.TestData.f);
    matlabbatch{4}.spm.spatial.normalise.write.woptions.vox  = [3 3 3];

    matlabbatch{5}.spm.spatial.normalise.write.subj.def      = cellstr(spm_file(testCase.TestData.a,'prefix','y_','ext','nii'));
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample = cellstr(spm_file(testCase.TestData.a,'prefix','m','ext','nii'));
    matlabbatch{5}.spm.spatial.normalise.write.woptions.vox  = [1 1 3];

    % Smooth
    %--------------------------------------------------------------------------
    matlabbatch{6}.spm.spatial.smooth.data = cellstr(spm_file(testCase.TestData.f,'prefix','w'));
    matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];

    spm_jobman('run',matlabbatch);
end

%% Those will be run once the test file is loaded / unloaded
function setupOnce(testCase)  % do not change function name
    % Directory containing the Auditory data
    %--------------------------------------------------------------------------
    addpath '/Users/enrico/Downloads/spm12/';
    testCase.TestData.data_path = fileparts(mfilename('fullpath'));
    if isempty(testCase.TestData.data_path), data_path = pwd; end
    fprintf('%-40s:', 'Downloading Auditory dataset...');
    urlwrite('http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.zip','MoAEpilot.zip');
    unzip(fullfile(testCase.TestData.data_path,'MoAEpilot.zip'));
    fprintf(' %30s\n', '...done');

    % Initialise SPM
    %--------------------------------------------------------------------------
    spm('Defaults','fMRI');
    spm_jobman('initcfg');
end

function teardownOnce(testCase)  % do not change function name
    delete README.txt README_analysis.txt 
    delete spm_2020Sep08.ps
    if isfolder('dummy') rmdir dummy s; end
    if isfolder('fM00223') rmdir fM00223 s; end
    if isfolder('sM00223') rmdir sM00223 s; end
    delete MoAEpilot.zip
end

%% Those will be run at the beginning/end of each test function
function setup(testCase)  % do not change function name
    testCase.TestData.f = spm_select('FPList', fullfile(testCase.TestData.data_path,'fM00223'), '^f.*\.img$');
    testCase.TestData.a = spm_select('FPList', fullfile(testCase.TestData.data_path,'sM00223'), '^s.*\.img$');
end
function teardown(testCase)  % do not change function name
    clear matlabbatch
end
