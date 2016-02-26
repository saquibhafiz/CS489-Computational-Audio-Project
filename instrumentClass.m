function class = instrumentClass(instrument)
    instruments = {'Cello', 'EbClarinet', 'Flute', 'Horn', 'Oboe', 'SopSax', 'Trumpet', 'Tuba', 'Viola', 'Violin'};
    classes = {'string', 'woodwind', 'woodwind', 'brass', 'woodwind', 'brass', 'brass', 'brass', 'string', 'string'};
    instrumentsToClass = containers.Map(instruments, classes);
    class = instrumentsToClass(instrument);
end