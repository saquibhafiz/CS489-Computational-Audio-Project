% Definition of crest factor obtained from: https://en.wikipedia.org/wiki/Crest_factor
% "Ratio of peak value to the effective value"

function crestFactor = getCrestFactor(signal)
    crestFactor = max(signal) / rms(signal);
end