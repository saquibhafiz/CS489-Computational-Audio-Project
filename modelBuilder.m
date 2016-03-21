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

save('unfilteredModelData', 'modelData', 'w', 'b', 's');

%% filter data
if ~exist('modelData', 'var')
    load('unfilteredModelData');
end

validIndx = ~any(isnan(modelData),2);

W = repmat({'W'}, w, 1);
B = repmat({'B'}, b, 1);
S = repmat({'S'}, s, 1);

s = sum(validIndx(w+b+1:end)~=0);
b = sum(validIndx(w+1:w+b)~=0);
w = sum(validIndx(1:w)~=0);

labels = {W{:}, B{:}, S{:}}';
labels = labels(validIndx,:);

filteredModelData = modelData(validIndx,:);

save('filteredModelDataLabel', 'filteredModelData', 'labels', 'w', 'b', 's');

%% build k models for each type of classification
k = 100;

if ~exist('filteredModelData', 'var') || ~exist('labels', 'var')
    load('filteredModelDataLabel');
end

averageSVMModelScore = 0;
averageKNNModelScore = 0;
averageDTreeModelScore = 0;

for i = 1:k
    n = w + b + s;

    rng('shuffle');
    randomPerm = randperm(n);
    testCutOff = floor(n * 0.7);

    randomizedModelData = filteredModelData(randomPerm,:);
    X = randomizedModelData(1:testCutOff,:);
    Xtest = randomizedModelData(testCutOff+1:end,:);

    randomizedModelLabels = labels(randomPerm,:);
    Y = randomizedModelLabels(1:testCutOff);
    Ytest = randomizedModelLabels(testCutOff+1:end);
    
    [svmModel, classes] = buildSVMModel(X, Y);
    svmScore = testSVMModel(svmModel, classes, Xtest, Ytest);
    averageSVMModelScore = averageSVMModelScore + svmScore;
end

averageSVMModelScore = averageSVMModelScore / k;
averageKNNModelScore = averageKNNModelScore / k;
averageDTreeModelScore = averageDTreeModelScore / k;
