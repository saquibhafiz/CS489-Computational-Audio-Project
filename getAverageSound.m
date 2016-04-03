function averageSound = getAverageSound(fileName, note)
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
        
        diffAmount = sum(var(soundMatrix));
        if diffAmount < leastDiffAmount
            averageSound = mean(soundMatrix);
            leastDiffAmount = diffAmount;
        end
    end
    
    averageSound = averageSound ./ max(abs(averageSound));
end