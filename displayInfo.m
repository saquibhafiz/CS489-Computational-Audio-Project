function displayInfo(fileName, note)
    [sig,Fs] = audioread(fileName);
    figure; title(fileName);
    subplot 221; plot(sig);
    sc = SpectralCentroid(sig, 100, 10, Fs);
%     pitch = noteToFreq(note);
%     sc = sc * pitch * pitch;
%     sc = fft(sc);
%     sc = sc(2:ceil(length(sc)/2));
    sc = sc/max(abs(sc));
    subplot 222; plot(sc);
    [h, s, v] = getAverageHarmonic(fileName, note);
    subplot 223; stem(h);
    subplot 224; plot(s);
    display(mean(v));
end
