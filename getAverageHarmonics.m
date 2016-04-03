function [averageHarmonics, averageSound] = getAverageHarmonics(fileName, note)
    averageSound = getAverageSound(fileName, note);
    averageHarmonics = abs(fft(averageSound));
    averageHarmonics = averageHarmonics(2:floor(length(averageHarmonics)/2));
    averageHarmonics = averageHarmonics ./ max(averageHarmonics);
end