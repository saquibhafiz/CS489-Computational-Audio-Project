%% initialize variables
clear; close all;

modelDataFiles = {'crestFactorValues', 'fundamentalHarmonicWeightFactorValues', 'oddEvenHarmonicRatioFactorValues', 'spectralCentroidVarianceFactorValues', 'phaseImpactFactorValues'};

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
clear;
load('filteredModelDataLabel');

k = 1000;
ks = 1:k;

N = w + b + s;
testCutOff = floor(N * 0.7);

brassCorrectlyPredicted = zeros(k, 4);
woodwindCorrectlyPredicted = zeros(k, 4);
stringCorrectlyPredicted = zeros(k, 4);
overallCorrectlyPredicted = repmat(N - testCutOff, [k 4]);

for i = ks
    rng('shuffle');
    randomPerm = randperm(N);

    randomizedModelData = filteredModelData(randomPerm,:);
    X = randomizedModelData(1:testCutOff,:);
    Xtest = randomizedModelData(testCutOff+1:end,:);

    randomizedModelLabels = labels(randomPerm,:);
    Y = randomizedModelLabels(1:testCutOff);
    Ytest = randomizedModelLabels(testCutOff+1:end);

    [svmModel, classes] = buildSVMModel(X, Y);
    svmPredictions = testSVMModel(svmModel, classes, Xtest);

    knnModel = buildKNNModel(X, Y);
    knnPredictions = testKNNModel(knnModel, Xtest);

    dTreeModel = buildDTreeModel(X, Y);
    dTreePredictions = testDTreeModel(dTreeModel, Xtest);
    
    hybridPredictions = hybridizePredictions([svmPredictions knnPredictions dTreePredictions]);

    b = 0;
    w = 0;
    s = 0;
    for j = 1:length(Ytest)
        if strcmp(Ytest(j), 'B')
            b = b + 1;
        elseif strcmp(Ytest(j), 'W')
            w = w + 1;
        elseif strcmp(Ytest(j), 'S')
            s = s + 1;
        end

        if strcmp(Ytest(j), svmPredictions(j))
            if strcmp(Ytest(j), 'B')
                brassCorrectlyPredicted(i, 1) = brassCorrectlyPredicted(i, 1) + 1;
            elseif strcmp(Ytest(j), 'W')
                woodwindCorrectlyPredicted(i, 1) = woodwindCorrectlyPredicted(i, 1) + 1;
            elseif strcmp(Ytest(j), 'S')
                stringCorrectlyPredicted(i, 1) = stringCorrectlyPredicted(i, 1) + 1;
            end
        else
            overallCorrectlyPredicted(i, 1) = overallCorrectlyPredicted(i, 1) - 1;
        end

        if strcmp(Ytest(j), knnPredictions(j))
            if strcmp(Ytest(j), 'B')
                brassCorrectlyPredicted(i, 2) = brassCorrectlyPredicted(i, 2) + 1;
            elseif strcmp(Ytest(j), 'W')
                woodwindCorrectlyPredicted(i, 2) = woodwindCorrectlyPredicted(i, 2) + 1;
            elseif strcmp(Ytest(j), 'S')
                stringCorrectlyPredicted(i, 2) = stringCorrectlyPredicted(i, 2) + 1;
            end
        else
            overallCorrectlyPredicted(i, 2) = overallCorrectlyPredicted(i, 2) - 1;
        end

        if strcmp(Ytest(j), dTreePredictions(j))
            if strcmp(Ytest(j), 'B')
                brassCorrectlyPredicted(i, 3) = brassCorrectlyPredicted(i, 3) + 1;
            elseif strcmp(Ytest(j), 'W')
                woodwindCorrectlyPredicted(i, 3) = woodwindCorrectlyPredicted(i, 3) + 1;
            elseif strcmp(Ytest(j), 'S')
                stringCorrectlyPredicted(i, 3) = stringCorrectlyPredicted(i, 3) + 1;
            end
        else
            overallCorrectlyPredicted(i, 3) = overallCorrectlyPredicted(i, 3) - 1;
        end
        
        if strcmp(Ytest(j), hybridPredictions(j))
            if strcmp(Ytest(j), 'B')
                brassCorrectlyPredicted(i, 4) = brassCorrectlyPredicted(i, 4) + 1;
            elseif strcmp(Ytest(j), 'W')
                woodwindCorrectlyPredicted(i, 4) = woodwindCorrectlyPredicted(i, 4) + 1;
            elseif strcmp(Ytest(j), 'S')
                stringCorrectlyPredicted(i, 4) = stringCorrectlyPredicted(i, 4) + 1;
            end
        else
            overallCorrectlyPredicted(i, 4) = overallCorrectlyPredicted(i, 4) - 1;
        end
    end

    n = b + w + s;

    brassCorrectlyPredicted(i,:) = brassCorrectlyPredicted(i,:)/b;
    woodwindCorrectlyPredicted(i,:) = woodwindCorrectlyPredicted(i,:)/w;
    stringCorrectlyPredicted(i,:) = stringCorrectlyPredicted(i,:)/s;
    overallCorrectlyPredicted(i,:) = overallCorrectlyPredicted(i,:)/n;
end

save('plotData', 'brassCorrectlyPredicted', 'woodwindCorrectlyPredicted', 'stringCorrectlyPredicted', 'overallCorrectlyPredicted');

%% graph data
clear;
load('plotData');
ks = 1:size(overallCorrectlyPredicted, 1);

brassCorrectlyPredicted = brassCorrectlyPredicted*100;
woodwindCorrectlyPredicted = woodwindCorrectlyPredicted*100;
stringCorrectlyPredicted = stringCorrectlyPredicted*100;
overallCorrectlyPredicted = overallCorrectlyPredicted*100;

mNum = 1;
f = figure;
plot(ks, brassCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, woodwindCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, stringCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, overallCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
legend('brass','woodwind','string','overall','Location','northwest');
title('SVM Model Prediction Rate'); xlabel('trial #'); ylabel('% correct'); ylim([0 100]);
saveas(f, 'svmPreditionRate.jpg');

mNum = 2;
f = figure;
plot(ks, brassCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, woodwindCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, stringCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, overallCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
legend('brass','woodwind','string','overall','Location','northwest');
title('KNN Model Prediction Rate'); xlabel('trial #'); ylabel('% correct'); ylim([0 100]);
saveas(f, 'knnPreditionRate.jpg');

mNum = 3;
f = figure;
plot(ks, brassCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, woodwindCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, stringCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, overallCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
legend('brass','woodwind','string','overall','Location','northwest');
title('DTREE Model Prediction Rate'); xlabel('trial #'); ylabel('% correct'); ylim([0 100]);
saveas(f, 'dTreePreditionRate.jpg');

mNum = 4;
f = figure;
plot(ks, brassCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, woodwindCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, stringCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
plot(ks, overallCorrectlyPredicted(:,mNum), 'LineWidth', 2); hold on;
legend('brass','woodwind','string','overall','Location','northwest');
title('Hybrid Model Prediction Rate'); xlabel('trial #'); ylabel('% correct'); ylim([0 100]);
saveas(f, 'hybridPreditionRate.jpg');

display(mean(brassCorrectlyPredicted));
display(std(brassCorrectlyPredicted));

display(mean(woodwindCorrectlyPredicted));
display(std(woodwindCorrectlyPredicted));

display(mean(stringCorrectlyPredicted));
display(std(stringCorrectlyPredicted));
