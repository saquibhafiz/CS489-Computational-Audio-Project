% Taken from http://www.mathworks.com/matlabcentral/fileexchange/19236-some-basic-audio-features/content/zcr.m
% and edited to suit our needs for our specifications as described in the
% documentation

function zeroCrossRate = getZeroCrossRate(signal, windowLength, step)
    curPos = 1;
    L = length(signal);
    numOfFrames = floor((L-windowLength)/step) + 1;
    zeroCrossRate = zeros(numOfFrames,1);
    for i = 1:numOfFrames
        window = (signal(curPos:curPos+windowLength-1));    
        window2 = zeros(size(window));
        window2(2:end) = window(1:end-1);
        zeroCrossRate(i) = (1/(2*windowLength)) * sum(abs(sign(window) - sign(window2)));
        curPos = curPos + step;
    end
end