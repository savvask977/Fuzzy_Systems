%% initialization

format compact
clear all;
clc;

%% Load and split data
data=importdata('haberman.data');
dataIn = data(:,1:3);
dataOut = data(:, 4);
preproc=1;
[trnData,chkData,tstData]=split_scale(data,preproc);
limitsOut = [min(trnData(:,end)), max(trnData(:,end))];
%% Clustering Per Class
iters = 1;
OAmat = zeros(141, 1);
kmat = zeros(141, 1);
rules = zeros(141, 1);
fisArray = [];
initialFis = [];

for radius=0.6:-0.0025:0.15
    close all;
    fprintf('Radius: %f \n', radius);
    [c1,sig1]=subclust(trnData(trnData(:,end)==1,:),radius);
    [c2,sig2]=subclust(trnData(trnData(:,end)==2,:),radius);
    num_rules=size(c1,1)+size(c2,1);
    x(iters) = num_rules;
 %Build FIS From Scratch
 fis=newfis('FIS_SC','sugeno');

 names_in={'in1','in2','in3'};
 for i=1:size(trnData,2)-1
    fis=addInput(fis,[0 1],"Name",names_in{i});
 end
 fis=addOutput(fis,[0 1],"Name",'out1');

 %Add Input Membership Functions
 name={'in1','in2','in3','in4', 'in5'};
 for i=1:size(trnData,2)-1
     for j=1:size(c1,1)
         fis=addMF(fis,name{i},'gaussmf',[sig1(i) c1(j,i)]);        
     end
     for j=1:size(c2,1)
         fis=addMF(fis,name{i},'gaussmf',[sig2(i) c2(j,i)]);
     end
 end

 %Add Output Membership Functions
 params=[zeros(1,size(c1,1)) ones(1,size(c2,1))];
 for i=1:num_rules
    fis=addMF(fis,'out1','constant',params(i));
 end

 %Add FIS Rule Base
 ruleList=zeros(num_rules,size(trnData,2));
 for i=1:size(ruleList,1)
     ruleList(i,:)=i;
 end
 ruleList=[ruleList ones(num_rules,2)];
 fis=addrule(fis,ruleList);

 %Train & Evaluate ANFIS
 steps=100;
 [trnFis,trnError,~,valFis,valError]=anfis(trnData,fis,steps,[],chkData);
   
 trainsteps = 1:steps;
 trnFig = figure;
 plot(trainsteps, trnError, trainsteps,valError,'LineWidth',2); grid on;
 legend('Training Error','Validation Error');
 xlabel('# of Epochs');
 ylabel('Error');
 title('ANFIS Classification with Scatter Partition');
 trnFile = strcat('habermanFig', num2str(iters));
 savefig(trnFig, trnFile);
 
 outputFis=evalfis(tstData(:,1:end-1),valFis);
 outputFis=round(outputFis);
    
 outputFis(outputFis < min(dataOut)) = min(dataOut);
 outputFis(outputFis > max(dataOut)) = max(dataOut);
    
 classes = max(dataOut) - min(dataOut) + 1;
 numDataTest = length(tstData(:,1:end-1));

 ErrorMatrix = zeros(classes, classes);

 for i = 1:length(tstData(:,end))
     ErrorMatrix(outputFis(i), tstData(i,end)) = ...
     ErrorMatrix(outputFis(i), tstData(i,end)) + 1;
 end

 trnFile = strcat('ErrorMatrix', num2str(iters));
 save(trnFile, 'ErrorMatrix');
    
 sumDiag = 0;
 for i = 1:classes
     sumDiag = sumDiag + ErrorMatrix(i, i);
 end
 OAtemp = sumDiag / numDataTest;
 UAtemp = zeros(classes, 1);
 PAtemp = zeros(classes, 1);
 xir = zeros(classes, 1);
 xrj = zeros(classes, 1);

 for i = 1:classes
     xir(i) = 0;
     xrj(i) = 0;
     for j = 1:classes
         xir(i) = xir(i) + ErrorMatrix(i, j);
         xrj(i) = xrj(i) + ErrorMatrix(j, i);
     end
     UAtemp(i) = ErrorMatrix(i, i) / xir(i);
     PAtemp(i) = ErrorMatrix(i, i) / xrj(i);
 end

 sumXr = 0;
 for i = 1:classes
     sumXr = sumXr + xir(i) * xrj(i);
 end
        
 khat = (numDataTest * sumDiag - sumXr) / (numDataTest^2 - sumXr);
 OAmat(iters) = OAtemp;
 kmat(iters) = khat;
 rules(iters) = length(valFis.rule);
 initialFis = [initialFis; fis];
 fisArray = [fisArray; valFis];
 iters = iters + 1;
 
end
save('initialFisArray.mat', 'initialFisArray');
save('fisArray.mat', 'fisArray');
radius = 0.6:-0.0025:0.1;

%% After i ran the code above, i  chose 2 models from the results depending on the accuracy.
idx5 = 5;
idx25 = 120;
radFinal = [radius(idx5), radius(idx25)];
in = load('errorMatrix5');
errorMatrix5 = in.errorMatrix;
in = load('errorMatrix120');
errorMatrix25 = in.errorMatrix;

initialFis5 = initialFis(idx5);
fis5 = fisArray(idx5);
initialFis25 = initialFis(idx25);
fis25 = fisArray(idx25);

% initial form
figure
subplot(2, 2, 1)
plotmf(initialFis5, 'input', 1)
subplot(2, 2, 2)
plotmf(initialFis5, 'input', 2)
subplot(2, 2, 3)
plotmf(initialFis5, 'input', 3)

% final form
figure
subplot(2, 2, 1)
plotmf(fis5, 'input', 1)
subplot(2, 2, 2)
plotmf(fis5, 'input', 2)
subplot(2, 2, 3)
plotmf(fis5, 'input', 3)

% initial form
figure
subplot(2, 2, 1)
plotmf(initialFis25, 'input', 1)
subplot(2, 2, 2)
plotmf(initialFis25, 'input', 2)
subplot(2, 2, 3)
plotmf(initialFis25, 'input', 3)

%final form
figure
subplot(2, 2, 1)
plotmf(fis25, 'input', 1)
subplot(2, 2, 2)
plotmf(fis25, 'input', 2)
subplot(2, 2, 3)
plotmf(fis25, 'input', 3)