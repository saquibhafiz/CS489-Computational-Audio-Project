function fundamentalHarmonicWeight = getFundamentalHarmonicWeight(harmonic)
    fundamentalHarmonicWeight = sum(harmonic(2:end)./(2:length(harmonic)))/harmonic(1);
end