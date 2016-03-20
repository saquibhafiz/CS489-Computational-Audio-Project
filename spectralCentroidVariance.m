%% Calculate factor values
clear; close all;

files = dir('audioClips/*.wav');

stringFactorValues = zeros(length(files), 2);
woodwindFactorValues = zeros(length(files), 2);
brassFactorValues = zeros(length(files), 2);

s = 1;
w = 1;
b = 1;

i = 1;

for file = files'
    tokenNames = regexp(file.name,'(?<instrument>\w+)\.[\w\W]*\.(?<note>\w{1,2}\d*)\.stereo\.wav','names');
    instrument = tokenNames(1).instrument;
    class = instrumentClass(instrument);
    
    fileName = strcat('audioClips/',file.name);
    [signal, Fs] = audioread(fileName);
    
    factorValue = var(getSpectralCentroid(signal, Fs/10, Fs/100, Fs));
    
    if strcmp('woodwind', class)
        woodwindFactorValues(w,:) = [i, factorValue];
        w = w + 1;
    elseif strcmp(class, 'brass')
        brassFactorValues(b,:) = [i, factorValue];
        b = b + 1;
    elseif strcmp(class, 'string')
        stringFactorValues(s,:) = [i, factorValue];
        s = s + 1;
    end
    
    i = i + 1;
end

w = w - 1;
b = b - 1;
s = s - 1;

woodwindFactorValues = woodwindFactorValues(1:w,:);
brassFactorValues = brassFactorValues(1:b,:);
stringFactorValues = stringFactorValues(1:s,:);

save('spectralCentroidVarianceFactorValues', 'woodwindFactorValues', 'brassFactorValues', 'stringFactorValues');

%% Use factor values
if ~exist('woodwindFactorValues', 'var') || ~exist('brassFactorValues', 'var') || ~exist('stringFactorValues', 'var')
    load('spectralCentroidVarianceFactorValues');
end

w = length(woodwindFactorValues);
b = length(brassFactorValues);
s = length(stringFactorValues);
i = w + b + s;

woodwindFactorAverage = mean(woodwindFactorValues(~isnan(woodwindFactorValues(:,2)), :));
woodwindFactorVar = var(woodwindFactorValues);
brassFactorAverage = mean(brassFactorValues(~isnan(brassFactorValues(:,2)), :));
brassFactorVar = var(brassFactorValues);
stringFactorAverage = mean(stringFactorValues(~isnan(stringFactorValues(:,2)), :));
stringFactorVar = var(stringFactorValues);

plot(woodwindFactorValues(:,1), woodwindFactorValues(:,2), 'og');
hold on;
plot(brassFactorValues(:,1), brassFactorValues(:,2), 'ok');
hold on;
plot(stringFactorValues(:,1), stringFactorValues(:,2), 'or');
hold on;

plot([0, i], [woodwindFactorAverage(2), woodwindFactorAverage(2)], 'g');
hold on;
plot([0, i], [brassFactorAverage(2), brassFactorAverage(2)], 'k');
hold on;
plot([0, i], [stringFactorAverage(2), stringFactorAverage(2)], 'r');
hold on;
title('Spectral Centroid Variance Factor');
ylabel('Spectral Centroid Variance Factor');
xlabel('sample #');
legend('Woodwind', 'Brass', 'String', 'Woodwind Average', 'Brass Average', 'String Average');
