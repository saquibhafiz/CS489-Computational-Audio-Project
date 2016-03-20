%% Calculate factor values
clear; close all;

files = dir('audioClips/*.wav');

stringFactorValues = zeros(length(files));
woodwindFactorValues = zeros(length(files));
brassFactorValues = zeros(length(files));

i = 1;
for file = files'
    tokenNames = regexp(file.name,'(?<instrument>\w+)\.[\w\W]*\.(?<note>\w{1,2}\d*)\.stereo\.wav','names');
    instrument = tokenNames(1).instrument;
    class = instrumentClass(instrument);
    
    fileName = strcat('audioClips/',file.name);
    [signal, Fs] = audioread(fileName);
    
    factorValue = getZeroCrossRate(signal, Fs/10, Fs/100);
    
    if strcmp('woodwind', class)
        woodwindFactorValues(i) = factorValue;
    elseif strcmp(class, 'brass')
        brassFactorValues(i) = factorValue;
    elseif strcmp(class, 'string')
        stringFactorValues(i) = factorValue;
    end
    
    i = i + 1;
end
i = i - 1;

save('zeroCrossoverRateFactorValues', 'woodwindFactorValues', 'brassFactorValues', 'stringFactorValues');

%% Use factor values
if ~exist('woodwindFactorValues', 'var') || ~exist('brassFactorValues', 'var') || ~exist('stringFactorValues', 'var')
    load('zeroCrossoverRateFactorValues');
end

woodwindFactorValues = woodwindFactorValues(1:i);
brassFactorValues = brassFactorValues(1:i);
stringFactorValues = stringFactorValues(1:i);

woodwindFactorAverage = mean(woodwindFactorValues);
woodwindFactorVar = var(woodwindFactorValues);
brassFactorAverage = mean(brassFactorValues);
brassFactorVar = var(brassFactorValues);
stringFactorAverage = mean(stringFactorValues);
stringFactorVar = var(stringFactorValues);

plot(1:i, woodwindFactorValues, 'og');
hold on;
plot(1:i, brassFactorValues, 'ok');
hold on;
plot(1:i, stringFactorValues, 'or');
hold on;

plot(linspace(1, i, 100*i), woodwindFactorAverage, 'g');
hold on;
plot(linspace(1, i, 100*i), brassFactorAverage, 'k');
hold on;
plot(linspace(1, i, 100*i), stringFactorAverage, 'r');
hold on;
title('zeroCrossoverRateFactorValues');
ylabel('Zero Crossover Rate');
xlabel('Number of file samples');
legend('Woodwind', 'Brass', 'String', 'Woodwind Average', 'Brass Average', 'String Average');
