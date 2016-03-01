function harmonics = getHarmonics(fileName, note)
    [x, Fs] = audioread(fileName);
    signalLength = length(x);
    freq = noteToFreq(note);

    DC = freq*signalLength/Fs;
    bound = floor(0.4*DC);
    
    X = fft(x);
    Xabs = abs(X);

    % base is the true frequency at which the DC component occurs
    [DC_val, base] = max(Xabs(1:DC+bound));

    % Update bounds with the DC frequency
    bound = floor(0.4*base);

    % 25 harmonics in total. 
    % Each row of harmonics has two entries: value of abs(X) and frequency at
    % which the ith harmonic peaks at, where i=1:25
    harmonics = zeros(25,2);

    for i=2:26,
        fi = base*i;
    
        % Using max function with a lower and upper bound to accommodate for
        % any potential frequency shifts as the signal is quasi-periodic
        [hval, index] = max(Xabs(fi-bound:fi+bound));
        harmonics(i-1,1) = hval;
        harmonics(i-1,2) = index + (fi-bound-1);
    end

    % Only keep the first column as the second column is only for testing
    % purposes
    harmonics = harmonics(:,1);

    % Normalize values to 0 and 1 inclusive
    maxVal = max(harmonics(:));
    harmonics = harmonics/maxVal;
end