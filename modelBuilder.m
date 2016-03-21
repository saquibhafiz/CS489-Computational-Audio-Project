%% initialize variables

clear; close all;

modelDataFiles = {'crestFactorValues', 'fundamentalHarmonicWeightFactorValues', 'oddEvenHarmonicRatioFactorValues', 'spectralCentroidVarianceFactorValues'};

modelData = [];

for m = 1:length(modelDataFiles)
    load(modelDataFiles{m});

    w = length(woodwindFactorValues);
    b = length(brassFactorValues);
    s = length(stringFactorValues);
    i = w + b + s;

    if isempty(modelData)
        modelData = zeros(i, length(modelDataFiles));
    end

    for n = 1:w
        modelData(n,m) = woodwindFactorValues(n,2);
    end

    for n = 1:b
        modelData(n+w,m) = brassFactorValues(n,2);
    end

    for n = 1:s
        modelData(n+w+b,m) = stringFactorValues(n,2);
    end
end

save('unfilteredModelData', 'modelData');

%% model scores

if ~exist('X', 'var') || ~exist('Y', 'var')
    load('modelVars');
end

i = 1;
for n = 1:size(X, 1)
    if X(n,1) < 4 && X(n,2) < 8
        X(i,:) = X(n,:);
        Y(i,:) = Y(n,:);
        i = i + 1;
    end
end
X = X(1:i,:);
Y = Y(1:i,:);

classes = unique(Y);
numClasses = numel(classes);
SVMModels = cell(numClasses,1);
rng(1); % For reproducibility (random number generator http://www.mathworks.com/help/matlab/ref/rng.html)

for j = 1:numClasses;
    indx = strcmp(Y, classes(j)); % Create binary classes for each classifier
    SVMModels{j} = fitcsvm(X, indx, 'ClassNames', [false true], 'Standardize', true,...
        'KernelFunction', 'RBF', 'BoxConstraint', 1);
end

save('model', 'SVMModels');
