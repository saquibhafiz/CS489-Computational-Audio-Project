function phaseImpact = getPhaseImpact(averagePhase)
    threshold = 0.07;
    count = 0;
    for i = 1:length(averagePhase)
        if abs(averagePhase(i)) > threshold
            count = count + 1;
        end
    end
    phaseImpact = count / length(averagePhase);
end