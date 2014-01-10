
clear all;

load('../storage/EXPFIXATIONPERIMG.mat'); % EXPFIXATIONPERIMG
load('../storage/EXPALLFeatures.mat'); % ALLFeatures

fixsize = size(EXPFIXATIONPERIMG{1});

for trial=1:10
    select = randperm(length(EXPFIXATIONPERIMG));
    feat = zeros(fixsize(1)*fixsize(2)*50,3);
    human = zeros(fixsize(1)*fixsize(2)*50,1);

    for sel=1:100
        idx = select(sel);
        c = imresize(ALLFeatures{idx}.ittikoch.top_level_feat_maps{1}, fixsize, 'bilinear');
        i = imresize(ALLFeatures{idx}.ittikoch.top_level_feat_maps{2}, fixsize, 'bilinear');
        o = imresize(ALLFeatures{idx}.ittikoch.top_level_feat_maps{3}, fixsize, 'bilinear');
        feat((sel-1)*fixsize(1)*fixsize(2)+1:sel*fixsize(1)*fixsize(2), 1) = c(:);
        feat((sel-1)*fixsize(1)*fixsize(2)+1:sel*fixsize(1)*fixsize(2), 2) = i(:);
        feat((sel-1)*fixsize(1)*fixsize(2)+1:sel*fixsize(1)*fixsize(2), 3) = o(:);

        human((sel-1)*fixsize(1)*fixsize(2)+1:sel*fixsize(1)*fixsize(2), 1) = double(EXPFIXATIONPERIMG{idx}(:))./255;
    end

    [x,resnorm,residual,exitflag,output,lambda]  =  lsqnonneg(feat, human);

    fprintf('%f,%f,%f\n', x(1), x(2), x(3));

end

