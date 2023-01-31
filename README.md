# Test hMRI processing
Testing some functions and features from the hMRI toolbox

## `cp_test_maskNaN.m`

Making sure that the conversion of `0`'s into `NaN`'s, for data format that can represent it (`float32` and `float64`), is not messing up the data. Conversely, nothing bad should happen to the (unsigned) integer data, which do not represent `NaN`

<u>References:</u>

- hMRI toolbox: https://hmri.info/
- mask issue & fix: https://github.com/hMRI-group/hMRI-toolbox/pull/50
