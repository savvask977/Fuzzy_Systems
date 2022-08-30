%% initialization

close all;
clear all;
clc;
%% Load and split data and normalize input

data = csvread('data.csv',1,1);
dataIn = data(:,1:178);
dataOut = data(:,179);
preproc = 1;
[trnData, chkData, tstData] = split_scale(data,preproc);
limitsOut = [min(trnData(:,end)), max(trnData(:,end))];
TrainData = trnData(:,1:end-1);
validateData = chkData(:,1:end-1);
checkData = tstData(:,1:end-1);

TrainDataOutput = trnData(:,end);
ValDataOutput = chkData(:,end);
CheckDataOutput = tstData(:,end);
%% Relief algorithm
[idx, weights] = relieff(TrainData,TrainDataOutput, 1000);
figure
bar(weights(idx))
xlabel('Predictor rank')
ylabel('Predictor importance weight')
save('reliefIdx.mat', 'idx')
save('reliefW.mat', 'weights')
%% 
NF = [4, 8 ,12, 16, 20];
ra = [ 0.6, 0.55 , 0.5, 0.45, 0.4];
sizeOfDataTrain = length(TrainData);
fisMatrix= [];
ErrorMatrix = zeros(length(NF), length(ra));
sumNaN = zeros(length(NF), length(ra)); 
iters = 1;
x=[];
for i = 1:length(NF)
    TrainDataInF = trnData(:, idx(1:NF(i)));
    for j = 1:length(ra)
        meanError = 0;
        c = cvpartition(sizeOfDataTrain, 'KFold', 5);
        for k = 1:5
            idxCV = training(c, k);
            CVinputForTrain = TrainDataInF(idxCV, :);
            CVinputForVal = TrainDataInF(~idxCV, :);
            CVoutputForTrain = TrainDataOutput(idxCV);
            CVoutputForVal = TrainDataOutput(~idxCV);
            tottr = [CVinputForTrain, CVoutputForTrain];
            [c1,sig1]=subclust(tottr(tottr(:,end)==1,:),ra(j));
            [c2,sig2]=subclust(tottr(tottr(:,end)==2,:),ra(j));
            [c3,sig3]=subclust(tottr(tottr(:,end)==3,:),ra(j));
            [c4,sig4]=subclust(tottr(tottr(:,end)==4,:),ra(j));
            [c5,sig5]=subclust(tottr(tottr(:,end)==5,:),ra(j));
            num_rules=size(c1,1)+size(c2,1)+size(c3,1)+size(c4,1)+size(c5,1);
            x(iters) = num_rules;
            %Build FIS From Scratch
            fis=newfis('FIS_SC','sugeno');
            names_in = {};
            for m=1:size(tottr,2)-1
            names_in{m}= ("inp" + m);
            end
            
            for n=1:size(tottr,2)-1
                fis=addInput(fis,[0 1],"Name",names_in{n});
            end
            fis=addOutput(fis,[1 5],"Name",'out1');

            %Add Input Membership Functions
            
             for i1=1:size(tottr,2)-1
                    for j1=1:size(c1,1)
                        fis=addMF(fis,names_in{i1},'gaussmf',[sig1(i1) c1(j1,i1)]);        
                    end
                    for j2=1:size(c2,1)
                        fis=addMF(fis,names_in{i1},'gaussmf',[sig2(i1) c2(j2,i1)]);
                    end
                    for j3=1:size(c3,1)
                        fis=addMF(fis,names_in{i1},'gaussmf',[sig3(i1) c3(j3,i1)]);
                    end
                    for j4=1:size(c4,1)
                        fis=addMF(fis,names_in{i1},'gaussmf',[sig4(i1) c4(j4,i1)]);
                    end
                    for j5=1:size(c5,1)
                        fis=addMF(fis,names_in{i1},'gaussmf',[sig5(i1) c5(j5,i1)]);
                    end
             end

             %Add Output Membership Functions
             
             params=[ones(1,size(c1,1)) 2*ones(1,size(c2,1)) 3*ones(1,size(c3,1)) 4*ones(1,size(c4,1)) 5*ones(1,size(c5,1))];
             for r=1:num_rules
                 fis=addMF(fis,'out1','constant',params(r));
             end

            %Add FIS Rule Base
            ruleList=zeros(num_rules,size(tottr,2));
            for r1=1:size(ruleList,1)
                   ruleList(r1,:)=r1;
            end
            ruleList=[ruleList ones(num_rules,2)];
            fis=addrule(fis,ruleList);
            [~, trnError, ~, fisOutput, validateError] = ...
            anfis([CVinputForTrain, CVoutputForTrain], fis, 100, NaN, [CVinputForVal, CVoutputForVal]);
            
            meanError = meanError + min(validateError);
            sumNaN(i, j) = sumNaN(i, j) + sum(isnan(trnError));
            fisMatrix= [fisMatrix; fisOutput];
            iters = iters +1;
        end
        meanError = meanError / 5;
        ErrorMatrix(i, j) = meanError;
        
    end
end
 
CrossValMin = inf;
for i = 1:length(NF)
    for j = 1:length(ra)
        if ErrorMatrix(i, j) < CrossValMin && sumNaN(i, j) < 10
            CrossValMin = ErrorMatrix(i, j);
            bestNF = i;
            bestRa = j;
        end
    end
end

TrainDataBest = TrainData(:, idx(1:NF(bestNF)));
ValDataBest = validateData(:, idx(1:NF(bestNF)));
CheckDataBest = checkData(:, idx(1:NF(bestNF)));


%% Train optimum model
besttr = [TrainDataBest, TrainDataOutput];

[c1,sig1]=subclust(besttr(besttr(:,end)==1,:),ra(bestRa));
[c2,sig2]=subclust(besttr(besttr(:,end)==2,:),ra(bestRa));
[c3,sig3]=subclust(besttr(besttr(:,end)==3,:),ra(bestRa));
[c4,sig4]=subclust(besttr(besttr(:,end)==4,:),ra(bestRa));
[c5,sig5]=subclust(besttr(besttr(:,end)==5,:),ra(bestRa));
num_rules1=size(c1,1)+size(c2,1)+size(c3,1)+size(c4,1)+size(c5,1);

 %Build FIS From Scratch
 fistr=newfis('FIS_SC','sugeno');
 names_in = {};
 for n2=1:size(besttr,2)-1
     names_in{n2}= ("inp" + n2);
 end  
 for n3=1:size(besttr,2)-1
    fistr=addInput(fistr,[0 1],"Name",names_in{n3});
 end
 fistr=addOutput(fistr,[1 5],"Name",'out1');

 %Add Input Membership Functions
            
 for i8=1:size(besttr,2)-1
     for j7=1:size(c1,1)
         fistr=addMF(fistr,names_in{i8},'gaussmf',[sig1(i8) c1(j7,i8)]);        
     end
     for j8=1:size(c2,1)
         fistr=addMF(fistr,names_in{i8},'gaussmf',[sig2(i8) c2(j8,i8)]);
     end
     for j9=1:size(c3,1)
         fistr=addMF(fistr,names_in{i8},'gaussmf',[sig3(i8) c3(j9,i8)]);
     end
     for j10=1:size(c4,1)
         fistr=addMF(fistr,names_in{i8},'gaussmf',[sig4(i8) c4(j10,i8)]);
     end
     for j11=1:size(c5,1)
         fistr=addMF(fistr,names_in{i8},'gaussmf',[sig5(i8) c5(j11,i8)]);
     end
 end

 %Add Output Membership Functions
 params=[ones(1,size(c1,1)) 2*ones(1,size(c2,1)) 3*ones(1,size(c3,1)) 4*ones(1,size(c4,1)) 5*ones(1,size(c5,1))];
 for r2=1:num_rules1
    fistr=addMF(fistr,'out1','constant',params(r2));
 end

 %Add FIS Rule Base
 ruleList=zeros(num_rules1,size(besttr,2));
 for r3=1:size(ruleList,1)
     ruleList(r3,:)=r3;
 end
 ruleList=[ruleList ones(num_rules1,2)];
 fistr=addrule(fistr,ruleList);

steps = 200;
[~, trnError, ~, bestFis, validateError] = ...
anfis([TrainDataBest, TrainDataOutput],fistr, steps, 1, [ValDataBest, ValDataOutput], 1);
trainSteps = 1:steps;

figure
plot(trainSteps, trnError, 'b', trainSteps, validateError, 'r', 'LineWidth', 2);
legend('er-train', 'er-validate');
writefis(fistr, 'initialFis');
writefis(bestFis, 'bestFis');


meanErrorOut = mean(CheckDataOutput);
ChkOutputFis = evalfis(CheckDataBest, bestFis);
errorChk = CheckDataOutput - ChkOutputFis;
rmse = sqrt(mean(errorChk .^ 2));
SSres = sum(errorChk .^ 2);
SStot = sum((CheckDataOutput - meanErrorOut) .^ 2);
Rsquared = 1 - SSres / SStot
nmse = SSres / SStot;
ndei = sqrt(nmse);
outChkNorm = evalfis(CheckDataBest, bestFis);
outChkFis = round(outChkNorm);
outChkFis(outChkFis < min(min(TrainDataOutput))) = min(min(TrainDataOutput));
outChkFis(outChkFis > max(max(TrainDataOutput))) = max(max(TrainDataOutput));

classes = max(TrainDataOutput) - min(TrainDataOutput) + 1;
numDataCheck = length(checkData);
ErrorMatrixOP = zeros(classes, classes);

for i = 1:length(CheckDataOutput)
    ErrorMatrixOP(outChkFis(i), CheckDataOutput(i)) = ...
    ErrorMatrixOP(outChkFis(i), CheckDataOutput(i)) + 1;
end

sumDiag = 0;
for i = 1:classes
    sumDiag = sumDiag + ErrorMatrixOP(i, i);
end
OA1 = sumDiag / numDataCheck;
UA1 = zeros(classes, 1);
PA1 = zeros(classes, 1);
xir = zeros(classes, 1);
xrj = zeros(classes, 1);

for i = 1:classes
    xir(i) = 0;
    xrj(i) = 0;
    for j = 1:classes
        xir(i) = xir(i) + ErrorMatrixOP(i, j);
        xrj(i) = xrj(i) + ErrorMatrixOP(j, i);
    end
    UA1(i) = ErrorMatrixOP(i, i) / xir(i);
    PA1(i) = ErrorMatrixOP(i, i) / xrj(i);
end

sumXr = 0;
for i = 1:classes
    sumXr = sumXr + xir(i) * xrj(i);
end

kHat1 = (numDataCheck * sumDiag - sumXr) / (numDataCheck^2 - sumXr);
errorFig = figure;
plot(errorChk);

%% figures 

figure
hold on;
plot(CheckDataOutput, 'b');
plot(ChkOutputFis, 'r--');
legend('output', 'predicted output');
hold off;

% initial form
figure
subplot(2, 2, 1)
plotmf(fistr, 'input', 5)
subplot(2, 2, 2)
plotmf(fistr, 'input', 10)
subplot(2, 2, 3)
plotmf(fistr, 'input', 12)
subplot(2, 2, 4)
plotmf(fistr, 'input', 16)

% final form
figure
subplot(2, 2, 1)
plotmf(bestFis, 'input', 5)
subplot(2, 2, 2)
plotmf(bestFis, 'input', 10)
subplot(2, 2, 3)
plotmf(bestFis, 'input', 12)
subplot(2, 2, 4)
plotmf(bestFis, 'input', 16)

%% last question - comparision of rules for same number of features

mfNumber2 = ones(20, 1) * 2;
mfType1 = char('gaussmf', 'gaussmf', 'gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf',...
                 'gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf');
fis2 = genfis1([TrainDataBest, TrainDataOutput], mfNumber2,mfType1,'constant');
fprintf('Grid partitioning with 2 membership functions per feature has %d rules!', length(fis2.rule));

mfNumber3 = ones(20, 1) * 3;
mfType2 = char('gaussmf', 'gaussmf', 'gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf',...
                 'gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf','gaussmf');
fis3 = genfis1([TrainDataBest, TrainDataOutput], mfNumber3,mfType2,'constant');
fprintf('Grid partitioning with 3 membership functions per feature has %d rules!', length(fis3.rule));