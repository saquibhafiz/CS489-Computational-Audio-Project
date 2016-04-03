function knnModel = buildKNNModel(X, Y)
    chiSqrDist = @(x,Z,wt)sqrt((bsxfun(@minus,x,Z).^2)*wt);
    w = [0.2; 0.2; 0.2; 0.2; 0.2];
    knnModel = fitcknn(X,Y,'NumNeighbors',floor(sqrt(length(Y))),'Standardize',1,'Distance',@(x,Z)chiSqrDist(x,Z,w));
end