function svmScore = testSVMModel(model, classes, X, Y)
    svmScore = 0;

    for j = 1:numel(classes);
        [~,score] = predict(model{j}, X);
        Scores(:,j) = score(:,2);
    end
    [~,maxScore] = max(Scores,[],2);

    predictions = classes(maxScore);

    for j = 1:length(Y)
        if predictions{j} == Y{j};
            svmScore = svmScore + 1;
        end
    end
    
    svmScore = svmScore / length(X);
end