function [SVMModels, classes] = buildSVMModel(X,Y)
    classes = unique(Y);
    numClasses = numel(classes);
    SVMModels = cell(numClasses,1);
    rng('shuffle');

    for j = 1:numClasses;
        indx = strcmp(Y, classes(j)); % Create binary classes for each classifier
        SVMModels{j} = fitcsvm(X, indx, 'ClassNames', [false true], 'Standardize', true,...
            'KernelFunction', 'RBF', 'BoxConstraint', 1);
    end
end