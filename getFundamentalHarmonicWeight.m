function fundamentalHarmonicWeight = getFundamentalHarmonicWeight(harmonic)
    fundamentalHarmonicWeight = harmonic(1)/sum(harmonic(2:end)./(2:length(harmonic)));
end