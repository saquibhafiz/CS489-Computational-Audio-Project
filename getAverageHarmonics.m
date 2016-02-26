function averageHarmonics = getAverageHarmonics(fileName, windowType, numPoints)

    [sound, fs] = audioread(fileName);
    numTotalSamples = length(sound);
    halfN = floor((numPoints-1)/2);

    switch windowType,
        case 'triangle'
            w = barlett(numPoints);
        case 'cosine'
            w = hann(numPoints);
        case 'none'
            w = ones(numPoints,1);
    end

    hopDistance = numPoints/2; % Default 2 hops per N points

    steps = 1;
    averageHarmonics = zeros(halfN - 1, 1);
    for n1=1:hopDistance:(numTotalSamples-numPoints+1),
        idx = (n1:n1+numPoints-1)';
        YY = fft(sound(idx).*w);
        averageHarmonics = averageHarmonics + abs(YY(2:halfN));
        steps = steps + 1;
    end
    averageHarmonics = averageHarmonics ./ steps;
    
end