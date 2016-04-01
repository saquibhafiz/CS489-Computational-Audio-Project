function svmPredictions = testSVMModel(model, classes, X)
%     Scores = zeros(numel(classes));
    for j = 1:numel(classes);
        [~,score] = predict(model{j}, X);
        size(score);
        Scores(:,j) = score(:,2);
    end
    [~,maxScore] = max(Scores,[],2);

    svmPredictions = classes(maxScore);
end