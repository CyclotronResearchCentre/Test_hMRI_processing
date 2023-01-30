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

function cp_test_maskNaN
% Main steps
% 1/ create some data
% 2/ save in various formats
% 3/ apply the masking procedure
% 4/ check the corrected images


% Get SPM's data types for images
Dtypes = spm_type;

% 1/ create some data
% Synthetic image to be generated:
% - 1/3 of points will be random non-zero values, positive & negative
% - 1/3 made of zeros
% - 1/3 made of NaNs
Img_sz = [2 4 3]; % image size
Img_val = zeros(Img_sz);
Img_val(:,:,1) = 10.^(randn(Img_sz(1:2))).*sign(randn(Img_sz(1:2)));
Img_val(:,:,3) = NaN;
N_negVal = sum(Img_val(:)<0);

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
    Viic = spm_create_vol(Vii);
    Viicd = spm_write_vol(Viic,Img_val);
end

end


