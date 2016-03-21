function knnModel = buildKNNModel(X, Y)
    knnModel = fitcknn(X,Y,'NumNeighbors',5,'Standardize',1);
end