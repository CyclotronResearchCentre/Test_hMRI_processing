% Function to test the mask creation and correction in the hMRI toolbox.
%
% Key point about 0's and Nan's:
% Dependign on the data format used (integer vs. float), NaN's and 0's are
% not handled identically. When NaN's can be represented, i.e. with float
% data, masked out voxels in an image MUST have a NaN value and not a 0, as
% a 0 would be implicitly considered as a legitimate value. When there is
% no NaN representation in the data format, i.e. with itnerger data, then
% voxel with a 0 value will be implicitly masked out.
%
% The aim of this function is to test the 0-to-NaN conversion by some bit
% of code available in the processing functions of the hMRI toolbox.
%
% References:
% - hMRI toolbox: https://hmri.info/
% - mask issue & fix: https://github.com/hMRI-group/hMRI-toolbox/pull/50
%__________________________________________________________________________
% Copyright (C) 2023 Cyclotron Research Centre

% Written by C. Phillips, 2023.
% GIGA Institute, University of Liege, Belgium

function res_check = cp_test_maskNaN
% Main steps
% 1/ create some data
% 2/ save in various formats
% 3/ apply the fixing procedure
% 4/ check the corrected images


% Get SPM's data types for images
Dtypes = spm_type;

% 1/ create some data
% 3D synthetic image to be generated, z-axis is of size 3 such that
% - z=1 made of points will be random non-zero values, positive & negative
% - z=2 made of zeros
% - z=3 made of NaNs
Img_sz = [2 4 3]; % image size
Img_val = zeros(Img_sz);
Img_val(:,:,1) = 10.^(randn(Img_sz(1:2))).*sign(randn(Img_sz(1:2)));
Img_val(:,:,3) = NaN;

% 2/ save data
% Save the same data in all formats
% use spm_vol, spm_create_vol, and spm_write_vol
pth_Dat = fullfile(pwd,'tmp_Dat');
if ~exist(pth_Dat,'dir'), mkdir(pth_Dat), end
for ii=1:numel(Dtypes)
    fn_ii = fullfile(pth_Dat,sprintf('Dat_%s.nii',spm_type(Dtypes(ii))));
    Vii = struct( ...
        'fname', fn_ii, ...
        'dim',   Img_sz, ...
        'dt',    [Dtypes(ii) 0], ...
        'mat',   eye(4) , ...
        'descrip', sprintf( 'Test %s data',spm_type(Dtypes(ii)) ));
    Vii = spm_create_vol(Vii);
    VDat(ii) = spm_write_vol(Vii,Img_val); %#ok<*AGROW>
end
fnDat = char(VDat(:).fname);

% 3/ apply the fixing procedure
% There are 2 ways of applying the 0-to-NaN conversion in hMRI.
% a) some lines of code in hmri_proc_MPMsmooth, that uses spm_imcalc. See
%    at line 148 and following
% b) the function hmri_proc_zero2nan for post hoc fix. Note that it fixes
%    directly the image, without creating a copy of the orginal!

% a) Apply the bits of code from hmri_proc_MPMsmooth
a_fnDat = spm_file(fnDat,'prefix','a_');
for ii=1:numel(Dtypes)
    NaNrep = spm_type(VDat(ii).dt(1),'nanrep'); % check if NanN-repr
    if NaNrep % turn 0's into NaN's if possible
        ic_flag.dtype = VDat(ii).dt(1);
        spm_imcalc(VDat(ii), a_fnDat(ii,:), ...
            'i1.*(i1./i1)',ic_flag);
    else % or simply copy the image
        copyfile(fnDat(ii,:),a_fnDat(ii,:))
    end
end

% b) apply hmri_proc_zero2nan on a *copy* of the images
% Copy images
b_fnDat = spm_file(fnDat,'prefix','b_');
for ii=1:numel(Dtypes)
    copyfile(fnDat(ii,:),b_fnDat(ii,:));
end
% Turn 0's into NaN's
hmri_proc_zero2nan(b_fnDat)

% 4/ Check the values are correct!
% Where there is NaN representation, all 0's are turned into NaN's
% Where there is no NaN representation, 0's are left untouched
% All non-0 and non-NaN values are the same.
% 
% See in subfunction for specific issues
% - integer values are scaled and rounded when saved on disk
% - unsigned integer set the negative values to zeros when saved on disk
% - float32 (single) files do not have the same resolution as standard 
%   float64 (double) format for variables
% => need to account for this

% all results for the N data types and 2 approaches
res_check = zeros(numel(Dtypes),2);
for ii=1:numel(Dtypes)
    res_check(ii,1) = check_img(Img_val,a_fnDat(ii,:),Dtypes(ii));
    res_check(ii,2) = check_img(Img_val,b_fnDat(ii,:),Dtypes(ii));
end

end

%% SUBFUNCTION

% Function to check if things are ok with the "fixed" image saved on disk.
% Example
% ii = 1; fnDat_ii = a_fnDat(ii,:); Dtypes_ii = Dtypes(ii);
function res_ch = check_img(Img_val,fnDat_ii,Dtypes_ii)

% By default the test is positive, i.e. there is no problem, unless proven
% otherwise
res_ch = 1;
% map volume
V_ii = spm_vol(fnDat_ii);

% check the format is as expected
if Dtypes_ii~=V_ii.dt(1),
    % printout the image type that is trouble
    fprintf('\nProblem "Data type", for file %s.\n', ...
        spm_file(fnDat_ii,'filename'))
    res_ch = 0;
end
% load in values
val = spm_read_vols(V_ii);
% perform all checks
if spm_type(Dtypes_ii,'nanrep') % deal with floats
    if sum(isnan(val(:))) ~= 2*prod(V_ii.dim(1:2))
        fprintf('\nProblem "number of Nans", for file %s.\n', ...
            spm_file(fnDat_ii,'filename'))
        res_ch = 0;
    end
    % check number of bytes used, if 4 -> turn orignal values in 'single'
    if spm_type(Dtypes_ii,'bits') == 32
        Img_val = single(Img_val);
    end
    if any(val(1:prod(V_ii.dim(1:2))) ~= Img_val(1:prod(V_ii.dim(1:2))))
        fprintf('\nProblem "values", for file %s.\n', ...
            spm_file(fnDat_ii,'filename'))
        res_ch = 0;
    end
else % deal with integers
    % round to nearest integer accounting for the scaling factor
    Img_val_t = round(Img_val/V_ii.pinfo(1))*V_ii.pinfo(1);
    % #0s due to rounding off
    r_zeros = sum(Img_val_t(1:prod(V_ii.dim(1:2)))==0);
    if spm_type(Dtypes_ii,'minval')<0 % deal with pos & neg integers
        % #0s due to negative values
        n_zeros = 0;
        % values to actually check
        l_val2check = find(Img_val_t(1:prod(V_ii.dim(1:2)))~=0);
    else % deal with positive integers only
        % #0s due to negative values
        n_zeros = sum(Img_val_t(1:prod(V_ii.dim(1:2)))<0);
        % values to actually check
        l_val2check = find(Img_val_t(1:prod(V_ii.dim(1:2)))>0);
    end
    
    % Total #0s expected
    exp_0s = 2 * prod(V_ii.dim(1:2)) + r_zeros + n_zeros;
    if exp_0s ~= sum(val(:)==0)
            fprintf('\nProblem "number of 0''s", for file %s.\n', ...
                spm_file(fnDat_ii,'filename'))
        res_ch = 0;
    end
    % Check the remaining values, if any
    if exp_0s<prod(V_ii.dim)
        diff_val = val(l_val2check) - Img_val_t(l_val2check);
        if any(abs(diff_val)>1e-6)
            % Weird thing happen when dealing with int32/uitn32, due to
            % some rounding off error
            % -> use a 10^-6 maximum difference
            % Probably need a better explanation and conversion!
%         if any(val(l_val2check) ~= Img_val_t(l_val2check))
            fprintf('\nProblem "values", for file %s.\n', ...
                spm_file(fnDat_ii,'filename'))
            res_ch = 0;
        end
    end
    
end

end


