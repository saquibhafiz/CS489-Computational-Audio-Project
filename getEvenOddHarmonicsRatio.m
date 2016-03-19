function evenOddHarmonicsRatio = getEvenOddHarmonicsRatio(harmonics)
    evenHarmonics = harmonics(2:2:length(harmonics));
    oddHarmonics = harmonics(1:2:length(harmonics));
    evenOddHarmonicsRatio = sum(evenHarmonics) / sum(oddHarmonics);
%     evenOddHarmonicsRatio = evenOddHarmonicsRatio / harmonics(1);
end