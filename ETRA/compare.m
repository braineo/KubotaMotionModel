% analysis on models
X = zeros(72,30);
group = zeros(72,1);

for i = 1:2
    for j = 1:3
        loadfile = sprintf('../Result/model0926_%d%d_201309292156.mat', i,j);
        load(loadfile);
        for subjecti = 1:12
            X(((i-1)*3+j-1)*12+subjecti,:)=EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune.weight';
            group(((i-1)*3+j-1)*12+subjecti) = (i-1)*3+j;
        end
    end
end
