function knnScore = testKNNModel(model, X, Y)
    predictions = predict(model, X);
    
    knnScore = 0;
    for j = 1:length(Y)
        if predictions{j} == Y{j};
            knnScore = knnScore + 1;
        end
    end
    knnScore = knnScore / length(X);
end