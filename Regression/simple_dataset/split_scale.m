%% Split - Preprocess Data


function [trnData,valData,chkData] = split_scale(data,preproc)

    idx=randperm(length(data));
    trnIdx=idx(1:round(length(idx)*0.6));
    valIdx=idx(round(length(idx)*0.6)+1:round(length(idx)*0.8));
    chkIdx=idx(round(length(idx)*0.8)+1:end);
    trnX=data(trnIdx,1:end-1);
    valX=data(valIdx,1:end-1);
    chkX=data(chkIdx,1:end-1);
    switch preproc
        case 1                      %Normalization to unit hypercube
            xmin=min(trnX,[],1);
            xmax=max(trnX,[],1);
            trnX=(trnX-repmat(xmin,[length(trnX) 1]))./(repmat(xmax,[length(trnX) 1])-repmat(xmin,[length(trnX) 1]));
            valX=(valX-repmat(xmin,[length(valX) 1]))./(repmat(xmax,[length(valX) 1])-repmat(xmin,[length(valX) 1]));
            chkX=(chkX-repmat(xmin,[length(chkX) 1]))./(repmat(xmax,[length(chkX) 1])-repmat(xmin,[length(chkX) 1]));
        case 2                      %Standardization to zero mean - unit variance
            mu=mean(data,1);
            sig=std(data,1);
            trnX=(trnX-repmat(mu,[length(trnX) 1]))./repmat(sig,[length(trnX) 1]);
            valX=(trnX-repmat(mu,[length(valX) 1]))./repmat(sig,[length(valX) 1]);
            chkX=(trnX-repmat(mu,[length(chkX) 1]))./repmat(sig,[length(chkX) 1]);
        otherwise
            disp('Not appropriate choice.')
    end
    trnData=[trnX data(trnIdx,end)];
    valData=[valX data(valIdx,end)];
    chkData=[chkX data(chkIdx,end)];

end
