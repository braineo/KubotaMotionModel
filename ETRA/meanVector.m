% draw mean vector
output = [1,2,3; 1,3,2; 1,4,2; 2,5,1; 2,5,3];
for i = 1:size(output,1)
    X1 = X(group==output(i,1),:);
    X2 = X(group==output(i,2),:);
    feati = output(i,3);
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
    outputcsv1 = sprintf('weight#%d%d%d_1.csv',output(i,:));
    outputcsv2 = sprintf('weight#%d%d%d_2.csv',output(i,:));
    fid1 = fopen(outputcsv1, 'w');
    fid2 = fopen(outputcsv2, 'w');
    fprintf(fid1, ',%f,%f,%f\n', mean(x1));
    fprintf(fid2, ',%f,%f,%f\n', mean(x2));
    fclose(fid1);
    fclose(fid2);
end