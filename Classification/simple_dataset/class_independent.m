%% initialization

format compact
clear all;
clc;

%% Load data - split them 

data = importdata('haberman.data');
dataIn = data(:,1:3);
dataOut = data(:, 4);
preproc = 1;
[trnData, chkData, tstData] = split_scale(data,preproc);
limitsOut = [min(trnData(:,end)), max(trnData(:,end))];
%% scatter partition
OAmat = zeros(201, 1);
kmat = zeros(201, 1);
rules = zeros(201, 1);
fisArray = [];
initialFis = [];

iters = 1;
for radius = 0.6:-0.0025:0.1
    close all;
    fprintf('Radius: %f \n', radius);
    fis=genfis2(trnData(:,1:end-1),trnData(:,end),radius);
    for i = 1:length(fis.output.mf)
            fis.output.mf(i).type = 'constant';
            fis.output.mf(i).params = fis.output.mf(i).params(1);
    end
    steps = 100;
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
    save('initialFis.mat', 'initialFis');
    save('fisArray.mat', 'fisArray');
    radius = 0.6:-0.0025:0.1;

%%  After i ran the code above, i  chose 2 models from the results depending on the accuracy.
  
idx5 = 20;
idx22 = 144;
radFinal = [radius(idx5), radius(idx22)];

in = load('errorMatrix20');
errorMatrix5 = in.errorMatrix;
in = load('errorMatrix144');
errorMatrix22 = in.errorMatrix;

initialFis5 = initialFis(idx5);
fis5 = fisArray(idx5);
initialFis22 = initialFis(idx22);
fis22 = fisArray(idx22);

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

%initial form
figure
subplot(2, 2, 1)
plotmf(initialFis22, 'input', 1)
subplot(2, 2, 2)
plotmf(initialFis22, 'input', 2)
subplot(2, 2, 3)
plotmf(initialFis22, 'input', 3)

%final form
figure
subplot(2, 2, 1)
plotmf(fis22, 'input', 1)
subplot(2, 2, 2)
plotmf(fis22, 'input', 2)
subplot(2, 2, 3)
plotmf(fis22, 'input', 3)
