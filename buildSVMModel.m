function buildSVMModel(X,Y)
    classes = unique(Y);
    numClasses = numel(classes);
    SVMModels = cell(numClasses,1);
    rng(1); % For reproducibility (random number generator http://www.mathworks.com/help/matlab/ref/rng.html)

    for j = 1:numClasses;
        indx = strcmp(Y, classes(j)); % Create binary classes for each classifier
        SVMModels{j} = fitcsvm(X, indx, 'ClassNames', [false true], 'Standardize', true,...
            'KernelFunction', 'RBF', 'BoxConstraint', 1);
    end
end