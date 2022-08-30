function fis = trapeziErgasiasFIS()
    fis = newfis('trapeziErgasias');
    fis = addvar(fis, 'input', 'e', [-1, 1]);
    fis = addvar(fis, 'input', 'de', [-1, 1]);
    fis = addvar(fis, 'output', 'du', [-1, 1]);

    fis = addmf(fis,'input', 1, 'NV','trimf',[-1 -1 -0.625]);
    fis = addmf(fis,'input', 1, 'NL','trimf',[-1.125 -0.75 -0.375]);
    fis = addmf(fis,'input', 1, 'NM','trimf',[-0.875 -0.5 -0.125]);
    fis = addmf(fis,'input', 1, 'NS','trimf',[-0.625 -0.25 0.125]);
    fis = addmf(fis,'input', 1, 'ZR','trimf',[-0.375 0 0.375]);
    fis = addmf(fis,'input', 1, 'PS','trimf',[-0.125 0.25 0.625]);
    fis = addmf(fis,'input', 1, 'PM','trimf',[0.125 0.5 0.875]);
    fis = addmf(fis,'input', 1, 'PL','trimf',[0.375 0.75 1.125]);
    fis = addmf(fis,'input', 1, 'PV','trimf',[0.625 1 1]);
    
    fis = addmf(fis,'input', 2, 'PV','trimf',[0.625 1 1]);
    fis = addmf(fis,'input', 2, 'PL','trimf',[0.375 0.75 1.125]);
    fis = addmf(fis,'input', 2, 'PM','trimf',[0.125 0.5 0.875]);
    fis = addmf(fis,'input', 2, 'PS','trimf',[-0.125 0.25 0.625]);
    fis = addmf(fis,'input', 2, 'ZR','trimf',[-0.375 0 0.375]);
    fis = addmf(fis,'input', 2, 'NS','trimf',[-0.625 -0.25 0.125]);
    fis = addmf(fis,'input', 2, 'NM','trimf',[-0.875 -0.5 -0.125]);
     fis = addmf(fis,'input', 2, 'NL','trimf',[-1.125 -0.75 -0.375]);
    fis = addmf(fis,'input', 2, 'NV','trimf',[-1 -1 -0.625]);

    fis = addmf(fis,'output', 1, 'NV','trimf',[-1 -1 -0.625]);
    fis = addmf(fis,'output', 1, 'NL','trimf',[-1.125 -0.75 -0.375]);
    fis = addmf(fis,'output', 1, 'NM','trimf',[-0.875 -0.5 -0.125]);
    fis = addmf(fis,'output', 1, 'NS','trimf',[-0.625 -0.25 0.125]);
    fis = addmf(fis,'output', 1, 'ZR','trimf',[-0.375 0 0.375]);
    fis = addmf(fis,'output', 1, 'PS','trimf',[-0.125 0.25 0.625]);
    fis = addmf(fis,'output', 1, 'PM','trimf',[0.125 0.5 0.875]);
    fis = addmf(fis,'output', 1, 'PL','trimf',[0.375 0.75 1.125]);
    fis = addmf(fis,'output', 1, 'PV','trimf',[0.625 1 1]);

    fis = setfis(fis,'defuzzMethod','coa');
    fis = setfis(fis, 'impMethod', 'prod');

    ruleList = [1 1 5 1 1; 2 1 6 1 1; 3 1 7 1 1; 4 1 8 1 1; 5 1 9 1 1; ...
                6 1 9 1 1; 7 1 9 1 1; 8 1 9 1 1; 9 1 9 1 1; ... 

                1 2 4 1 1; 2 2 5 1 1; 3 2 6 1 1; 4 2 7 1 1; 5 2 8 1 1; ...
                6 2 9 1 1; 7 2 9 1 1; 8 2 9 1 1; 9 2 9 1 1; ...

                1 3 3 1 1; 2 3 4 1 1; 3 3 5 1 1; 4 3 6 1 1; 5 3 7 1 1; ...
                6 3 8 1 1; 7 3 9 1 1; 8 3 9 1 1; 9 3 9 1 1; ...

                1 4 2 1 1; 2 4 3 1 1; 3 4 4 1 1; 4 4 5 1 1; 5 4 6 1 1;...
                6 4 7 1 1; 7 4 8 1 1; 8 4 9 1 1; 9 4 9 1 1; ...

                1 5 1 1 1; 2 5 2 1 1; 3 5 3 1 1; 4 5 4 1 1; 5 5 5 1 1;...
                6 5 6 1 1; 7 5 7 1 1; 8 5 8 1 1; 9 5 9 1 1; ...

                1 6 1 1 1; 2 6 1 1 1; 3 6 2 1 1; 4 6 3 1 1; 5 6 4 1 1;...
                6 6 5 1 1; 7 6 6 1 1; 8 6 7 1 1; 9 6 8 1 1; ...

                1 7 1 1 1; 2 7 1 1 1; 3 7 1 1 1; 4 7 2 1 1; 5 7 3 1 1;...
                6 7 4 1 1; 7 7 5 1 1; 8 7 6 1 1; 9 7 7 1 1; ...

                1 8 1 1 1; 2 8 1 1 1; 3 8 1 1 1; 4 8 1 1 1; 5 8 2 1 1;...
                6 8 3 1 1; 7 8 4 1 1; 8 8 5 1 1; 9 8 6 1 1; ...

                1 9 1 1 1; 2 9 1 1 1; 3 9 1 1 1; 4 9 1 1 1; 5 9 1 1 1;...
                6 9 2 1 1; 7 9 3 1 1; 8 9 4 1 1; 9 9 5 1 1];
        
    fis = addrule(fis, ruleList);
    
end
