%%initialize
format compact;
clear all;
close all;
clc;
%rng('default'); better to have random splitted data

%%Load data and split them
startData = csvread('supercon.csv',1,0);
sizeOfData = length(startData);

DatIn = startData(1:sizeOfData, 1:81);
DatOut = startData(1:sizeOfData, 82);

idxData = randperm(sizeOfData);

%input data
TrainData = DatIn(idxData(1:floor(end * 0.6)), :);
validateData = DatIn(idxData((floor(end * 0.6) + 1):floor(end * 0.8)), :);
checkData = DatIn(idxData((floor(end * 0.8) + 1):end), :);


%ouput data
TrainDataOutput = DatOut(idxData(1:floor(end * 0.6)), :);
ValDataOutput = DatOut(idxData((floor(end * 0.6) + 1):floor(end * 0.8)), :);
CheckDataOutput = DatOut(idxData((floor(end * 0.8) + 1):end), :);


%% Relieff algorithm
    [idx, weights] = relieff(TrainData, TrainDataOutput, 1000);
    figure
    bar(weights(idx))
    xlabel('Predictor rank')
    ylabel('Predictor Importance')
    save('reliefIdx.mat', 'idx')
    save('reliefW.mat', 'weights')
    %%featureSel = idx(1:5);
%% subtractive clustering of data

NF = [3, 6, 9, 12];
ra = [0.5, 0.4, 0.3, 0.2];
rules = []; 
sizeOfDataTrain = length(TrainData);
fisMatrix= [];
ErrorMatrix = zeros(length(NF), length(ra));
sumNaN = zeros(length(NF), length(ra));
iters =1;
for i = 1:length(NF)
    TrainDataInF = TrainData(:, idx(1:NF(i)));
    for j = 1:length(ra)
        meanError = 0;
        c = cvpartition(sizeOfDataTrain, 'KFold', 5);
        for k = 1:5
            idxCV = training(c, k);
            CVinputForTrain = TrainDataInF(idxCV, :);
            CVinputForVal = TrainDataInF(~idxCV, :);
            CVoutputForTrain = TrainDataOutput(idxCV);
            CVoutputForVal = TrainDataOutput(~idxCV);
            fis = genfis2(CVinputForTrain, CVoutputForTrain, ra(j));
            [~, trainError, ~, fisOutput, validateError] = ...
            anfis([CVinputForTrain, CVoutputForTrain], fis, 100, NaN, [CVinputForVal, CVoutputForVal]);
            meanError = meanError + min(validateError);
            sumNaN(i, j) = sumNaN(i, j) + sum(isnan(trainError));
            fisMatrix= [fisMatrix; fisOutput];
        end
        meanError = meanError / 5;
        ErrorMatrix(i, j) = meanError;
    end
    rules(iters) = length(fis.rule);
    iters = iters +1;
end
  
CrossValMin = inf;
for i = 1:length(NF)
    for j = 1:length(ra)
        if ErrorMatrix(i, j) < CrossValMin && sumNaN(i, j) < 15
            CrossValMin = ErrorMatrix(i, j);
            bestNF = i;
            bestRa = j;
        end
    end
end

TrainDataBest = TrainData(:, idx(1:NF(bestNF)));
ValDataBest = validateData(:, idx(1:NF(bestNF)));
CheckDataBest = checkData(:, idx(1:NF(bestNF)));

%% training optimum model



fistr= genfis2(TrainDataBest, TrainDataOutput,ra(bestRa));
steps = 200;
[~, trainError, ~, bestFis, validateError] = ...
anfis([TrainDataBest, TrainDataOutput],fistr, steps, 1, [ValDataBest, ValDataOutput], 1);
trainSteps = 1:steps;

%trainFig = figure;
figure
plot(trainSteps, trainError, 'b', trainSteps, validateError, 'r', 'LineWidth', 2);
legend('er-train', 'er-validate');
writefis(fistr, 'initialFis');
writefis(bestFis, 'bestFis');

meanErrorOut = mean(CheckDataOutput);
CheckDataOutputFis = evalfis(CheckDataBest, bestFis);
errorChk = CheckDataOutput - CheckDataOutputFis;
rmse = sqrt(mean(errorChk .^ 2));
SSres = sum(errorChk .^ 2);
SStot = sum((CheckDataOutput - meanErrorOut) .^ 2);
Rsquared = 1 - SSres / SStot;
nmse = SSres / SStot;
ndei = sqrt(nmse);
errorFig = figure;
plot(errorChk);

%% figures 
figure
hold on;
plot(CheckDataOutput, 'b');
plot(CheckDataOutputFis, 'r--');
legend('Output', 'Prediction');
hold off;

figure
subplot(2, 2, 1)
plotmf(fistr, 'input', 2)
subplot(2, 2, 2)
plotmf(fistr, 'input', 4)
subplot(2, 2, 3)
plotmf(fistr, 'input', 8)
subplot(2, 2, 4)
plotmf(fistr, 'input', 10)

figure
subplot(2, 2, 1)
plotmf(bestFis, 'input', 2)
subplot(2, 2, 2)
plotmf(bestFis, 'input', 4)
subplot(2, 2, 3)
plotmf(bestFis, 'input', 8)
subplot(2, 2, 4)
plotmf(bestFis, 'input', 10)

%% last question - comparision of rules for same number of features
mfNumber2 = ones(12, 1) * 2;
mfType1 = char('gaussmf', 'gaussmf', 'gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf');
fis2 = genfis1([TrainDataBest, TrainDataOutput], mfNumber2,mfType1,'constant');
fprintf('Grid partitioning with 2 membership functions per input has %d rules', length(fis2.rule));

mfNumber3 = ones(12, 1) * 3;
mfType2 = char('gaussmf', 'gaussmf', 'gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf');
fis3 = genfis1([TrainDataBest, TrainDataOutput], mfNumber3,mfType2,'constant');
fprintf('Grid partitioning with 3 membership functions per input has %d rules', length(fis3.rule));
