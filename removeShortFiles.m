clear; close all;

files = dir('audioClips/*.wav');

i = 1;
for file = files'
    tokenNames = regexp(file.name,'(?<instrument>\w+)\.[\w\W]*\.(?<note>\w{1,2}\d*)\.stereo\.wav','names');
    instrument = tokenNames(1).instrument;
    note = tokenNames(1).note;
    freq = noteToFreq(note);
    
    fileName = strcat('audioClips/',file.name);
    [signal, Fs] = audioread(fileName);
    periods = length(signal)/freq;

    if periods < 50
        delete(fileName);
        i = i + 1;
    end
end