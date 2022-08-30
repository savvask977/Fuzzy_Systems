%%initialize
clc
close all;
clear all;
%rng('default');
%% Load data and Split 
data=load('airfoil_self_noise.dat');
preproc=1;
[trnData,valData,chkData]=split_scale(data,preproc);

%% train models

    trainSteps = 1:600;
    
    % TSK_Model_1 -- singleton 2 mf
    mfNumberTSK1 = [2 2 2 2 2];
    mfTypeTSK1 = char('gbellmf', 'gbellmf', 'gbellmf', 'gbellmf', 'gbellmf');
    tsk1 = genfis1(trnData, mfNumberTSK1, mfTypeTSK1, 'constant');

    [~, trnErTSK1, ~, fisValTSK1, valErTSK1] = ...
    anfis(trnData, tsk1,600,NaN, valData);

    tsk1F = fisValTSK1;
  
    figure
    plot(trainSteps, trnErTSK1, 'b', trainSteps, valErTSK1, 'r', 'LineWidth', 2);
    legend('er-train', 'er-validate');
    xlabel('Epochs');
    title('Learning curves for TSK Model-1');

    writefis(tsk1F, 'TSK1.fis');
    
    figure
    hold on;
    for i = 1:5 
        subplot(2, 3, i)
        plotmf(tsk1F, 'input', i);
    end
    hold off;
    
    
    % TSK_Model_2 -- singleton 3 mf
    
    mfNumberTSK2 = [3 3 3 3 3];
    mfTypeTSK2 = char('gbellmf', 'gbellmf', 'gbellmf', 'gbellmf', 'gbellmf');
    tsk2 = genfis1(trnData, mfNumberTSK2, mfTypeTSK2, 'constant');

    [~, trnErTSK2, ~, fisValTSK2, valErTSK2] = ...
    anfis(trnData, tsk2,600, NaN, valData);

    tsk2F = fisValTSK2;
  
    figure
    plot(trainSteps, trnErTSK2, 'b', trainSteps, valErTSK2, 'r', 'LineWidth', 2);
    legend('er-train', 'er-validate');
    xlabel('Epochs');
    title('Learning curves for TSK Model-2');

    writefis(tsk2F, 'TSK2.fis');
    
    figure
    hold on;
    for i = 1:5 
        subplot(2, 3, i)
        plotmf(tsk2F, 'input', i);
    end
    hold off;
    
    
    % TSK_Model_3 -- polynomial 2 mf
    mfNumberTSK3 = [2 2 2 2 2 ];
    mfTypeTSK3 = char('gbellmf', 'gbellmf', 'gbellmf', 'gbellmf', 'gbellmf');
    tsk3 = genfis1(trnData, mfNumberTSK3, mfTypeTSK3, 'linear');

    [~, trnErTSK3, ~, fisValTSK3, valErTSK3] = ...
    anfis(trnData, tsk3, 600, NaN, valData);

    tsk3F = fisValTSK3;
  
    figure
    plot(trainSteps, trnErTSK3, 'b', trainSteps, valErTSK3, 'r', 'LineWidth', 2);
    legend('er-train', 'er-validate');
    xlabel('Epochs');
    title('Learning curves for TSK Model-3');

    writefis(tsk3F, 'TSK3.fis');
    
    figure
    hold on;
    for i = 1:5 
        subplot(2, 3, i)
        plotmf(tsk3F, 'input', i);
    end
    hold off;
    
    
    % TSK_Model_4 -- polynomial 3 mf
    
    mfNumberTSK4 = [3 3 3 3 3];
    mfTypeTSK4 = char('gbellmf', 'gbellmf', 'gbellmf', 'gbellmf', 'gbellmf');
    tsk4 = genfis1(trnData, mfNumberTSK4, mfTypeTSK4, 'linear');

    [~, trnErTSK4, ~, fisValTSK4, valErTSK4] = ...
    anfis(trnData, tsk4, 600, NaN, valData);

    tsk4F = fisValTSK4;
  
    figure
    plot(trainSteps, trnErTSK4, 'b', trainSteps, valErTSK4, 'r', 'LineWidth', 2);
    legend('er-train', 'er-validate');
    xlabel('Epochs');
    title('Learning curves for TSK Model-4');

    writefis(tsk4F, 'TSK4.fis');
    
    figure
    hold on;
    for i = 1:5 
        subplot(2, 3, i)
        plotmf(tsk4F, 'input', i);
    end
    hold off;

%% evaluate model
meanOut = mean(chkData(:, 6));

% TSK_Model_1
outChkFisTSK1 = evalfis(chkData(:, 1:5), tsk1F);
errorTSK1 = chkData(:, 6) - outChkFisTSK1;
rmseTSK1 = sqrt(mean(errorTSK1 .^ 2))
SSresTSK1 = sum(errorTSK1 .^ 2);
SStotTSK1 = sum((chkData(:, 6) - meanOut) .^ 2);
RsquaredTSK1 = 1 - SSresTSK1 / SStotTSK1
nmseTSK1 = SSresTSK1 / SStotTSK1
ndeiTSK1 = sqrt(nmseTSK1)
figure
plot(errorTSK1);

% TSK_Model_2
outChkFisTSK2 = evalfis(chkData(:, 1:5), tsk2F);
errorTSK2 = chkData(:, 6) - outChkFisTSK2;
rmseTSK2 = sqrt(mean(errorTSK2 .^ 2))
SSresTSK2 = sum(errorTSK2 .^ 2);
SStotTSK2 = sum((chkData(:, 6) - meanOut) .^ 2);
RsquaredTSK2 = 1 - SSresTSK2 / SStotTSK2
nmseTSK2 = SSresTSK2 / SStotTSK2
ndeiTSK2 = sqrt(nmseTSK2)
figure
plot(errorTSK2);

%TSK_Model_3
outChkFisTSK3 = evalfis(chkData(:, 1:5), tsk3F);
errorTSK3 = chkData(:, 6) - outChkFisTSK3;
rmseTSK3 = sqrt(mean(errorTSK3 .^ 2))
SSresTSK3 = sum(errorTSK3 .^ 2);
SStotTSK3 = sum((chkData(:, 6) - meanOut) .^ 2);
RsquaredTSK3 = 1 - SSresTSK3 / SStotTSK3
nmseTSK3 = SSresTSK3 / SStotTSK3
ndeiTSK3 = sqrt(nmseTSK3)
figure
plot(errorTSK3);

%TSK_Model_4
outChkFisTSK4 = evalfis(chkData(:, 1:5), tsk4F);
errorTSK4 = chkData(:, 6) - outChkFisTSK4;
rmseTSK4 = sqrt(mean(errorTSK4 .^ 2));
SSresTSK4 = sum(errorTSK4 .^ 2);
SStotTSK4 = sum((chkData(:, 6) - meanOut) .^ 2);
RsquaredTSK4 = 1 - SSresTSK4 / SStotTSK4;
nmseTSK4 = SSresTSK4 / SStotTSK4;
ndeiTSK4 = sqrt(nmseTSK4);
figure
plot(errorTSK4);
