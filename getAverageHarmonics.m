function [averageHarmonics, averageSound] = getAverageHarmonics(fileName, note)

    [sound, fs] = audioread(fileName);
    freq = noteToFreq(note);
    stepRatioBetweenNotes = 2^(1/12);
    maxFreq = freq * stepRatioBetweenNotes;
    minFreq = freq / stepRatioBetweenNotes;
    
    leastDiffAmount = Inf;
    
    for f = minFreq:maxFreq
        singleSampleLength = floor(fs / f);
        soundMatrix = vec2mat(sound, singleSampleLength);
        soundMatrix = soundMatrix(1:end-1,:);
        soundMatrix = soundMatrix';
        soundMatrix = soundMatrix ./ repmat(max(soundMatrix), size(soundMatrix, 1), 1);
        soundMatrix = soundMatrix';
%         
%         stdDevSound = std(soundMatrix);
%         meanSound = mean(soundMatrix);
% 
%         averageSoundIndx = zeros(size(soundMatrix, 1));
%         for n = 1:size(soundMatrix, 1)
%             if (sum(abs(soundMatrix(n, :) - meanSound) <= 1.5*stdDevSound) == size(soundMatrix, 2))
%                 averageSoundIndx(n) = 1;
%             end
%         end
%         
%         soundMatrix = soundMatrix(averageSoundIndx == 1, :);
        
        diffAmount = sum(var(soundMatrix));
        if diffAmount < leastDiffAmount
            averageSound = mean(soundMatrix);
            leastDiffAmount = diffAmount;
        end
    end
    
    averageSound = averageSound ./ max(abs(averageSound));
    
    averageHarmonics = abs(fft(averageSound));
    averageHarmonics = averageHarmonics ./ max(averageHarmonics);
    averageHarmonics = averageHarmonics(2:floor(length(averageHarmonics)/2));
end