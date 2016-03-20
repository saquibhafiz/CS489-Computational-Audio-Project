files = dir('..\samples\extracted originial');
warning('off','all')
for file = files'
    filename = strcat('..\samples\extracted originial\', file.name);
    if ~isempty(strfind(filename, 'aif'))
        [sound, fs, nbits, chunkdata] = aiffread(filename);
        sound = double(sound(:,1) + sound(:,2))/2;
        step = 10;
        window = 100;
        sc = getSpectralCentroid(sound, window, step, fs);

        start = 1;
        last = 1;
        maxWindow = 0;
        bestStart = 1;
        bestLast = 1;
        for n = 1:length(sc)
            if sc(n) == 0
                start = last;
                last = n;
                
                if last - start > maxWindow
                    bestStart = start;
                    bestLast = last;
                    maxWindow = last - start;
                end
            end
        end

        sound = sound(bestStart*step+1:bestLast*step-1);
        sound = sound/max(abs(sound));
        display(filename);
        audiowrite(strrep(file.name, 'aif', 'wav'), sound, fs);
    end
end