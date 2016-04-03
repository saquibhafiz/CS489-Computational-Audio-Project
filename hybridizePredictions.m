function hybridPredictions = hybridizePredictions(predictions)
    hybridPredictions = predictions(:,1);
    for i = 1:size(predictions,1)
        if strcmp(predictions(i,2),predictions(i,3)) && ~strcmp(predictions(i,1),predictions(i,3))
            hybridPredictions(i) = predictions(i,2);
        end
    end
end