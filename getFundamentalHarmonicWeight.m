function fundamentalHarmonicWeight = getFundamentalHarmonicWeight(harmonic)
    fundamentalHarmonicWeight = sum(harmonic(2:end))/harmonic(1);
end