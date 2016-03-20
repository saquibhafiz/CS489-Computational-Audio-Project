function oddEvenHarmonicsRatio = getOddEvenHarmonicsRatio(harmonics)
    evenHarmonics = harmonics(2:2:length(harmonics));
    oddHarmonics = harmonics(1:2:length(harmonics));
    oddEvenHarmonicsRatio = sum(oddHarmonics) / sum(evenHarmonics);
end