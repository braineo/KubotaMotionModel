groupi = 1:6;
combo = [1,2;1,3;2,3;4,5;4,6;5,6;1,4;2,5;3,6];
n = 12;
featName={'color', 'intensity', 'orientation', 'face'};
k=1;
for i = 1:size(combo,1)
    X1 = X(group==combo(i,1),:);
    X2 = X(group==combo(i,2),:);
    if(combo(i,:) == [2 5])
        feati = 1:4;
    else
        feati = 1:3;
    end
    
    for feati = feati
        x1 = [];
        x2 = [];
        for regioni = 1:3
            if(feati ~= 4);
                rangeL = (regioni-1)*10+1+3*(feati-1);
                rangeR = (regioni-1)*10+3+3*(feati-1);
                x1 = [x1, X1(:,rangeL:rangeR)];
                x2 = [x2, X2(:,rangeL:rangeR)];
                p = size(x1,2);
            else
                rangeL = regioni*10;
                x1 = [x1, X1(:,rangeL)];
                x2 = [x2, X2(:,rangeL)];
            end
        end
    Y= (x1-x2);
    y = mean(Y);
    YY = Y';
    ymean = y';
    ss = 0;
    for j = 1:n
        ss = ss + (YY(:,j)-ymean)*(YY(:,j)-ymean)';
    end
    disp(combo(i,:));
    disp(featName{feati});
%     ss = covMarket(Y);
    S = ss/(n-1);
    T2 = n*ymean'*S^(-1)*ymean;
    F = (n-p)/p/(n-1)*T2;
    ret.F = F;
    ret.combo = combo(i,:);
    ret.featName = featName{feati};
    result{k} = ret;
    k=k+1;
    end
end