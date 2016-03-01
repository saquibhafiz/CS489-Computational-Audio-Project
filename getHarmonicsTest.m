clear;
close all;

% TODO: Test: given back the harmonic values, re-construct a signal and 
% compare with original.
[harmonics] = getHarmonics('audioClips/Flute.nonvib.ff.C4.stereo.wav', 'C4');