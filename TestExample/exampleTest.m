% example test file for example.m
% run with results = runtests('exampleTest.m')

%% Main function to generate tests
function tests = exampleTest
    tests = functiontests(localfunctions);
end

%% the test function(s)
%% see https://de.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html 
function testFunctionA(testCase)
    actRoot = example(3*3);
    expRoot = 3;
    verifyEqual(testCase,actRoot,expRoot)
end
function testFunctionB(testCase)
    actRoot = example(-1);
    expRoot = 1i;
    verifyEqual(testCase,actRoot,expRoot)
end







%% Those will be run once the test file is loaded / unloaded
function setupOnce(testCase)  % do not change function name

end
function teardownOnce(testCase)  % do not change function name
% change back to original path, for example
end

%% Those will be run at the beginning/end of each test function
function setup(testCase)  % do not change function name
% open a figure, for example
end
function teardown(testCase)  % do not change function name
% close figure, for example
end
