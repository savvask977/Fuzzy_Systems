%%initialization

close all;
clear all;


%% Design of car's movement
v=0.05;
dvmax = 1;
dhmax=1;
% the corners in the space
c1 = [5; 1];
c2 = [6; 2];
c3 = [7; 3];
corners = [c1, c2, c3];
targetPos = [10; 3.2];
posStart = [4; 0.4];
startAngle = [0; -45; -90];
fis=generateCarFIS();
%% plot the path the car follows after we design 
for i =1:3
    [traj, theta, time] = simAvoidObstacles(fis, posStart, startAngle(i), v, corners);
    carPath(traj, corners, targetPos);
    figure
    plot(time, theta);
    xlabel('timesteps');
    ylabel('theta[o]');
    title('Speed Angle');
end
%% function to simulate 
function [path, angledat, t] = simAvoidObstacles(fis, posStart, startAngle, v, c)
    
    steps = 200;
    t = 1:steps;
    path = zeros(2, steps);
    angledat = zeros(steps, 1);
    pos = posStart;
    angle = startAngle;
    for i = 1:steps
        path(:, i) = pos;        
        diff = abs(c - pos);
        if pos(2) <= c(2, 1)
            dh = diff(1, 1);
        elseif pos(2) <= c(2, 2)
            dh = diff(1, 2);
        elseif pos(2) < c(2, 3)
            dh = diff(1, 3);
        else
            dh = 1;
        end
        if pos(1) <= c(1, 1)
            dv = 1;
        elseif pos(1) <= c(1, 2)
            dv = diff(2, 1);
        elseif pos(1) < c(1, 3)
            dv = diff(2, 2);
        else
            dv = diff(2, 3);
        end
        if dh > 1
            dh = 1;
        elseif dh < 0
            dh = 0;
        end  
        if dv > 1
            dv = 1;
        end
        angledat(i) = angle;
        dangle = evalfis([dh, dv, angle], fis);
        angle = angle + dangle;
        angle = mod(angle + 180, 360) - 180;
        dpos = [cosd(angle); sind(angle)] * v;  
        pos = pos + dpos;
        
    end
end
%% function to plot
function carPath( tr, corners, targetPos)

    if max(tr(1, :)) > 11
        hormax = max(tr(1, :));
    else
        hormax = 11;
    end

    if min(tr(1, :)) < 0
        hormin = min(tr(1, :));
    else
        hormin = 3;
    end
    
    if max(tr(2, :)) > 5
        vermax = max(tr(2, :));
    else
        vermax = 5;
    end

    if min(tr(2, :)) < 0
        vermin = min(tr(2, :));
    else
        vermin = 0;
    end
    figure;
    hold on;
    plot(tr(1, :), tr(2, :), 'g', 'Linewidth', 2);
    plot(corners(1, 1):corners(1, 2), corners(2, 1) * ones(size(corners(1, 1):corners(1, 2))), 'k', 'LineWidth', 2);
    plot(corners(1, 2):corners(1, 3), corners(2, 2) * ones(size(corners(1, 2):corners(1, 3))), 'k', 'LineWidth', 2);
    plot([corners(1, 3):hormax, hormax], corners(2, 3) * ones(size([corners(1, 3):hormax, hormax])), 'k', 'LineWidth', 2);
    plot(corners(1, 1) * ones(size([vermin:corners(2, 1), corners(2, 1)])), [vermin:corners(2, 1), corners(2, 1)], 'k', 'LineWidth', 2);
    plot(corners(1, 2) * ones(size(corners(2, 1):corners(2, 2))), corners(2, 1):corners(2, 2), 'k', 'LineWidth', 2);
    plot(corners(1, 3) * ones(size(corners(2, 2):corners(2, 3))), corners(2, 2):corners(2, 3), 'k', 'LineWidth', 2);
    plot(targetPos(1), targetPos(2), 'rx', 'MarkerSize', 12);
    plot(tr(1, 1), tr(2, 1), 'ro', 'MarkerSize', 12);
    xlim([hormin, hormax]);
    ylim([vermin, vermax]);
    title('Car Path');
    hold off;
    
end