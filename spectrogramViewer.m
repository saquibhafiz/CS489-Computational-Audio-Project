%% initialize variables

clear; close all;

files = dir('audioClips/*.wav');

%% find harmonic scores
class = cell(length(files), 1);
harmonics = cell(length(files), 1);

i = 1;
for file = files'
    tokenNames = regexp(file.name,'(?<instrument>\w+)\.[\w\W]*\.(?<note>\w{1,2}\d*)\.stereo\.wav','names');
    instrument = tokenNames(1).instrument;
    class{i} = instrumentClass(instrument);
    note = tokenNames(1).note;
    freq = noteToFreq(note);
    
    fileName = strcat('audioClips/',file.name);
    harmonics{i} = getAverageHarmonics(fileName, note);
    if (length(harmonics{i}) < 9)
        i = i-1;
        continue;
    end
    i = i+1;
end
i = i-1;

harmonics = harmonics(1:i);
class = class(1:i);

save('rawFeatures', 'harmonics', 'class');

%% process raw features

if ~exist('harmonics', 'var') || ~exist('class', 'var')
    load('rawFeatures');
end

x = zeros(i, 2);
y = class;
for j = 1:i
    harmonic = harmonics{j};
    evenOddHarmonicsRatio = getEvenOddHarmonicsRatio(harmonic);

    earlyHarmonicWeight = sum(harmonic(2:end)./(2:length(harmonic))/harmonic(1));
    
    x(j,1) = evenOddHarmonicsRatio;
    x(j,2) = earlyHarmonicWeight;
end

X = x(1:i,:);
Y = y(1:i);
save('modelVars', 'X', 'Y');

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

%% predict for granularity

if ~exist('SVMModels', 'var')
    load('model');
end

granulartiy = 1000;
x1Gran = (max(X(:,1))-min(X(:,1)))/granulartiy;
x2Gran = (max(X(:,2))-min(X(:,2)))/granulartiy;
[x1Grid, x2Grid] = meshgrid(min(X(:,1)):x1Gran:max(X(:,1)), min(X(:,2)):x2Gran:max(X(:,2)));
xGrid = [x1Grid(:), x2Grid(:)];
N = size(xGrid ,1);
scores = zeros(N, numClasses);

for j = 1:numClasses;
    [~, score] = predict(SVMModels{j}, xGrid);
    scores(:,j) = score(:,2); % Second column contains positive-class scores
end

[~,maxScore] = max(scores,[],2);

%% plot figure

figure;
h(1:3) = gscatter(xGrid(:,1),xGrid(:,2),maxScore,...
    [0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1]);
hold on;
h(4:6) = gscatter(X(:,1),X(:,2),Y);
title('{\bf Infoooo}');
xlabel('EvenOddHarmonicRatio');
ylabel('Harmonic Weight');
legend({'string region', 'woodwind region', 'brass region',...
    'observed string', 'observed woodwind', 'observed brass'},...
    'Location', 'Northwest');
axis tight;
hold off;