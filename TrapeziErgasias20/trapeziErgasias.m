%%initialization

close all;
clear all;

%% Enter the work table transfer function
numP = 25;
denP = [1 10.1 1];
Gp = tf(numP,denP);

%% Calculate the classical controller functions

c=0.3;

numC = [1 c];
denC = [1 0];

Gc = tf(numC, denC);
initG = Gc * Gp;
figure
rlocus(initG)
K = 1.2;
KP = K;
KI = c * KP;
Go = K * initG;
Gcl = feedback(Go, 1, -1);

figure;
step(Gcl);
systemInfo = stepinfo(Gcl);
rt = systemInfo.RiseTime;
os = systemInfo.Overshoot / 100;

%% Design of the FLC

dt = 0.01;
Ti = KP / KI;
normalPar=50;
% Gains-initial values
alpha = Ti;
Ke = 1;
K1 = KP / (alpha * Ke);

% Gains-final values
K1 = 10;
Ke = 2;
alpha = 0.4;
Kd = alpha * Ke;

if exist('trapeziErgasias.fis', 'file') == 2
    disp('Wait for the fis model to load');
    fis = readfis('trapeziErgasias');
else
    disp('FIS model is being generated!');
    fis = trapeziErgasiasFIS(); 
    writefis(fis, 'trapeziErgasias.fis');
end


%% scenario1
r=50;
t1 =[];
y1 =[];

t = 0;
y = 0;
dy = 0;
u = 0;

el = 1e-8;
del = 1e-6;
maxt = 20;

e = r - y;
de = -dy;
eNorm = e / normalPar;

while ((abs(e) > el || abs(de) > del) && t < maxt)
   
    t1 = [t1; t];
    y1 = [y1; y];
    preveNorm = eNorm;
    e = r - y;
    eNorm = e / normalPar;
    e1 = Ke * eNorm;
    de1 = (eNorm - preveNorm) * Kd / dt;
    
    de = de1 * normalPar;
    
    if e1 < -1
        e1 = -1;
    elseif e1 > 1
        e1 = 1;
    end
    if de1 < -1
        de1 = -1;
    elseif de1 > 1
        de1 = 1;
    end
    duOut = evalfis([e1, de1],fis);
    duNorm = duOut * K1 * dt;
    du = duNorm * normalPar;
    u = u + du;
    ddy = -denP(2) * dy - denP(3) * y + numP * u;
    t = t + dt;
    y = y + dy * dt;
    dy = dy + ddy * dt;
    
end

rsimul = r * ones(size(t1));
y1fin = lsim(Gcl, rsimul, t1);

figure;
hold on;
plot(t1, y1, 'g', 'LineWidth', 2);
plot(t1, y1fin, ':r', 'LineWidth', 2);
plot(t1, r * ones(size(t1)), '--k');
legend({'x-FZ-PI' , 'r'} ,'FontSize', 13);
xlabel('t[s]');
ylabel('x[o]');
title('Work Table');
hold off;

OSFuzzy = (max(y1) - r) / r;
idx10 = sum(y1 <= 5);
idx90 = sum(y1 <= 45);
RTFuzzy = t1(idx90) - t1(idx10);
figure 
gensurf(fis)

%% scenario2-first part
r=50;
t=0;
time1 = 0:dt:5;
time2 = (5 + dt):dt:10;
time3 = (10 + dt):dt:15;
f1 = 50 * ones(size(time1));
f2 = 20 * ones(size(time2));
f3 = 40 * ones(size(time3));
ftotal = [f1, f2, f3];
t21 = [time1, time2, time3];
iters = 0; 
maxt = 15;

y21 = [];
y = 0;
dy = 0;
u = 0;

e = r - y;
de = -dy;
eNorm = e / normalPar;
while (t < maxt)
    iters = iters + 1;
    t = t21(iters);
    y21 = [y21; y];
    preveNorm = eNorm;
    e = ftotal(iters) - y;
    eNorm = e / normalPar;
    
    e1 = Ke * eNorm;
    de1 = (eNorm - preveNorm) * Kd / dt;
    de = de1 * normalPar;   
    if e1 < -1
        e1 = -1;
    elseif e1 > 1
        e1 = 1;
    end    
    if de1 < -1
        de1 = -1;
    elseif de1 > 1
        de1 = 1;
    end    
    duOut = evalfis([e1, de1], fis);
    duNorm = duOut * K1 * dt;    
    du = duNorm * normalPar;    
    u = u + du;   
    ddy = -denP(2) * dy - denP(3) * y + numP * u;  
    y = y + dy * dt;
    dy = dy + ddy * dt;
    
end

figure;
hold on;
plot(t21, y21, 'b', 'LineWidth', 2);
plot(t21, ftotal, '--k');
legend({'x-FZ-PI' , 'r'} ,'FontSize', 13);
xlabel('t[s]');
ylabel('x[o]');
title('Work Table');
hold off;

%% second part 
r=50;
t=0;
time1 = 0:dt:5;
time2 = (5 + dt):dt:10;
time3 = (10+ dt):dt:20;
f1 = 10 * time1;
f2 = 50 * ones(size(time2));
f3 = 50 - 6.25 * (time3 - 10);

ftotal = [f1, f2, f3];
t22 = [time1, time2, time3];
iters = 0; 
maxt = 20;
y22 = [];

y = 0;
dy = 0;
u = 0;

e = r - y;
de = -dy;
eNorm = e / normalPar;
while (t < maxt)
   
    iters = iters + 1;
    t = t22(iters);
    y22 = [y22; y];
    preveNorm = eNorm;
    e = ftotal(iters) - y;
    eNorm = e / normalPar;    
    e1 = Ke * eNorm;
    de1 = (eNorm - preveNorm) * Kd / dt;
    
    de = de1 * normalPar;
    if e1 < -1
        e1 = -1;
    elseif e1 > 1
        e1 = 1;
    end    
    if de1 < -1
        de1 = -1;
    elseif de1 > 1
        de1 = 1;
    end   
    duOut = evalfis([e1, de1], fis);
    duNorm = duOut * K1 * dt;   
    du = duNorm * normalPar;   
    u = u + du;  
    ddy = -denP(2) * dy - denP(3) * y + numP * u;  
    y = y + dy * dt;
    dy = dy + ddy * dt;
    
end

figure;
hold on;
plot(t22, y22, 'b', 'LineWidth', 2);
plot(t22, ftotal, '--k');
legend({'x-FZ-PI' , 'r'} ,'FontSize', 13);
xlabel('t[s]');
ylabel('x[o]');
title('Work Table');
hold off;