function [averagePhase, averageSound] = getAveragePhase(fileName, note)
    averageSound = getAverageSound(fileName, note);
    min = Inf;
    for i = 1:50
        x = circshift(averageSound, [0 i]);
        X = fft(x);
        Xphase = angle(X);
        Xmag = abs(X);
        Xmag = Xmag./max(abs(Xmag));
        Y = Xphase.*Xmag;
        Y = Y(2:floor(length(Y)/2));
        if abs(Y(1)) < min
            min = abs(Y(1));
            averagePhase = Y;
        end
    end
end