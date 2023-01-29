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

end


