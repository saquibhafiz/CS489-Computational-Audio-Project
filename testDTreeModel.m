function dTreeScore = testDTreeModel(model, X, Y)
    predictions = predict(model, X);
    
    dTreeScore = 0;
    for j = 1:length(Y)
        if predictions{j} == Y{j};
            dTreeScore = dTreeScore + 1;
        end
    end
    dTreeScore = dTreeScore / length(X);
end