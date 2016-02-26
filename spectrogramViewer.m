%% initialize variables

clear; close all;

files = dir('*.wav');
x = zeros([length(files), 2]);
y = cell([length(files), 1]);

%% find harmonic scores

i = 0;
for file = files'
    i = i+1;
    if ~isempty(strfind(file.name, 'pizz'))
        i = i-1;
        continue;
    end
    tokenNames = regexp(file.name,'(?<instrument>\w+)\.[\w\W]*\.(?<note>\w{1,2}\d*)\.stereo\.wav','names');
    instrument = tokenNames(1).instrument;
    class = instrumentClass(instrument);
    note = tokenNames(1).note;
    freq = noteToFreq(note);
    
    harmonics = getAverageHarmonics(file.name, 'cosine', 2^14, 0.5);
    if (length(harmonics) < 9)
        i = i-1;
        continue;
    end
    
    evenHarmonics = harmonics(2:2:length(harmonics));
    oddHarmonics = harmonics(3:2:length(harmonics));
    evenOddHarmonicsRatio = sum(evenHarmonics) / sum(oddHarmonics);
    evenOddHarmonicsRatio = evenOddHarmonicsRatio / harmonics(1);
    
    earlyHarmonicWeight = sum(harmonics'./(1:length(harmonics))/harmonics(1));
    
    x(i,1) = evenOddHarmonicsRatio;
    x(i,2) = earlyHarmonicWeight;
    y{i} = class;
end

X = x(1:i,:);
Y = y(1:i);
save('harmonicsModelVars', 'X', 'Y');

%% model scores

if ~exist('X', 'var') || ~exist('Y', 'var')
    load('harmonicsModelVars');
end

classes = unique(Y);
numClasses = numel(classes);
SVMModels = cell(numClasses,1);
rng(1); % For reproducibility (random number generator http://www.mathworks.com/help/matlab/ref/rng.html)

for j = 1:numClasses;
    indx = strcmp(Y, classes(j)); % Create binary classes for each classifier
    SVMModels{j} = fitcsvm(X, indx, 'ClassNames', [false true], 'Standardize', true,...
        'KernelFunction', 'RBF', 'BoxConstraint', 1);
end

save('harmonicsModel', 'SVMModels');

%% predict for granularity

if ~exist('SVMModels', 'var')
    load('harmonicsModel');
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
title('{\bf Harmonic Score}');
xlabel('EvenOddHarmonicRatio');
ylabel('Harmonic Score');
legend({'string region', 'woodwind region', 'brass region',...
    'observed string', 'observed woodwind', 'observed brass'},...
    'Location', 'Northwest');
axis tight;
hold off;