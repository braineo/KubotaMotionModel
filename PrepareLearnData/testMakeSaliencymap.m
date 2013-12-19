function [NSS_tuned0, NSS_tuned1, NSS_tuned2, NSS_flat] = testMakeSaliencymap(ALLFeatures, weight1, testingdata)

%clear all
% ------------------
%ディスプレイと目との距離(m)
set_length_d2e = 1.33;
%解像度(pixel)とそれに対応する実寸(m)
set_kaizodo = 768.0;
set_nagasa = 0.802;
get_angle = @(d) (atan(d*set_nagasa/set_kaizodo/set_length_d2e)*180.0/pi);
get_distance = @(a) (tan(a*pi/180.0)*set_length_d2e*set_kaizodo/set_nagasa);
% ------------------

% Inputs
IMGS = 'C:\hg\Master\data\exp\EXP201109\images\final_resize'; %Change this to the path on your local computer
imagefiles = dir(fullfile(IMGS, '*.jpg'));
numImgs = length(imagefiles);

%fprintf('Load EXPALLFeatures...'); tic
%load('../storage/EXPALLFeatures.mat'); % ALLFeatures
%fprintf([num2str(toc), ' seconds \n']);

% サンプルを取得

%fprintf('Load EXPALLFixations...'); tic
%load('../storage/EXPALLFixations.mat'); % EXPALLFixations
%fprintf([num2str(toc), ' seconds \n']);

minimize_scale = 3;
width = 1366;
height = 768;
M = round(height/minimize_scale);
N = round(width/minimize_scale);
fixsize = [M N];

kyokai = {get_distance(6), get_distance(9), get_distance(12), get_distance(16), get_distance(22), get_distance(80)};

%outputcsv = 'result.csv';
%fid = fopen(outputcsv, 'w');

fprintf('Creating infos_base...\n'); tic
infos_base = [];
for tm=1:M
    for tn=1:N
        infos_base = [infos_base; [tn tm 1 0 0 0]];
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

th1 = get_distance(1.0)/3;

weight2 = zeros(size(weight1));
for j=1:size(weight1, 1)
    weight2(j,:)=100*weight1(j,:)./sum(weight1(j,:));
end

NSS_tuned0 =[];
NSS_tuned1 =[];
NSS_tuned2 =[];
NSS_flat =[];

fprintf('%d testing datas\n', length(testingdata));
fprintf('Start testing... '); tic
for testidx=1:length(testingdata)

    if(mod(testidx,fix(length(testingdata)/10))==0)
        fprintf('*');
    end


    imgidx = testingdata{testidx}.imgidx;

    c1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{1}, fixsize, 'bilinear');
    c2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{2}, fixsize, 'bilinear');
    c3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{3}, fixsize, 'bilinear');
    i1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{1}, fixsize, 'bilinear');
    i2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{2}, fixsize, 'bilinear');
    i3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{3}, fixsize, 'bilinear');
    o1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{1}, fixsize, 'bilinear');
    o2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{2}, fixsize, 'bilinear');
    o3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{3}, fixsize, 'bilinear');
    color = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{1}, fixsize, 'bilinear');
    intensity = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{2}, fixsize, 'bilinear');
    orientation = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{3}, fixsize, 'bilinear');

    nss_Tt0 = [];
    nss_Tt1 = [];
    nss_Tt2 = [];
    nss_Tf = [];
    for i=2:size(testingdata{testidx}.medianXY, 1)
        if(testingdata{testidx}.medianXY(i, 1) < 0 || testingdata{testidx}.medianXY(i, 2) < 0 || ...
           testingdata{testidx}.medianXY(i, 1) >= width || testingdata{testidx}.medianXY(i, 2) >= height)
            continue
        end
        
        % 0-0.4は1に四捨五入されるようにする。（infosのインデックスは1-widthまでなのに注意）
        px_ = round(testingdata{testidx}.medianXY(i-1, 1)/minimize_scale + 0.5);
        py_ = round(testingdata{testidx}.medianXY(i-1, 2)/minimize_scale + 0.5);
        nx_ = round(testingdata{testidx}.medianXY(i, 1)/minimize_scale + 0.5);
        ny_ = round(testingdata{testidx}.medianXY(i, 2)/minimize_scale + 0.5);

        infos = infos_base;
        infos(:,3) = imgidx.*ones_;
        
        %fprintf('P(%f,%f),N(%f,%f)\n', px_, py_, nx_, ny_);
        
        % 中心からの距離を計算
        infos(:,4) = sqrt((nx_.*ones_-infos(:,1)).*(nx_.*ones_-infos(:,1))+(ny_.*ones_-infos(:,2)).*(ny_.*ones_-infos(:,2)));
        infos(:,5) = sqrt((px_.*ones_-infos(:,1)).*(px_.*ones_-infos(:,1))+(py_.*ones_-infos(:,2)).*(py_.*ones_-infos(:,2)));
        
        dis = norm([px_-nx_ py_-ny_]);
        for k=1:length(kyokai)
            if(dis < kyokai{k}/minimize_scale)
                calNp = k;
                break
            end
        end
        
        for k=1:length(kyokai)
            infos(find(infos(:,5)<kyokai{k}/minimize_scale&infos(:,6)==0),6) = k;
        end
        % imshow(double(reshape(infos(:,6), fix(N), fix(M)))'./max(infos(:,6)));
        kyokaiIdxMat = reshape(infos(:,6), fix(N), fix(M))';
        
        result_tuned0 = zeros(fixsize);
        result_tuned1 = zeros(fixsize);
        result_tuned2 = zeros(fixsize);
        result_flat = zeros(fixsize);
        for k=1:length(kyokai)
            %if(calNp ~= k)
            %    continue
            %end
            calIdx = find(kyokaiIdxMat(:,:)==k);
            result_tuned0(calIdx) = ...
            weight2(7,1).*c1(calIdx) + weight2(7,2).*c3(calIdx) + weight2(7,3).*c3(calIdx) + ...
            weight2(7,4).*i1(calIdx) + weight2(7,5).*i2(calIdx) + weight2(7,6).*i3(calIdx) + ...
            weight2(7,7).*o1(calIdx) + weight2(7,8).*o2(calIdx) + weight2(7,9).*o3(calIdx);
            result_tuned1(calIdx) = ...
            weight1(k,1).*c1(calIdx) + weight1(k,2).*c3(calIdx) + weight1(k,3).*c3(calIdx) + ...
            weight1(k,4).*i1(calIdx) + weight1(k,5).*i2(calIdx) + weight1(k,6).*i3(calIdx) + ...
            weight1(k,7).*o1(calIdx) + weight1(k,8).*o2(calIdx) + weight1(k,9).*o3(calIdx);
            result_tuned2(calIdx) = ...
            weight2(k,1).*c1(calIdx) + weight2(k,2).*c3(calIdx) + weight2(k,3).*c3(calIdx) + ...
            weight2(k,4).*i1(calIdx) + weight2(k,5).*i2(calIdx) + weight2(k,6).*i3(calIdx) + ...
            weight2(k,7).*o1(calIdx) + weight2(k,8).*o2(calIdx) + weight2(k,9).*o3(calIdx);
            result_flat(calIdx) = (1/3).*color(calIdx) + (1/3).*intensity(calIdx) + (1/3).*orientation(calIdx);
        end

        [result_flat, meanVec_flat, stdVec_flat] = convert4NSS(result_flat);
        [result_tuned0, meanVec_tuned0, stdVec_tuned0] = convert4NSS(result_tuned0);
        [result_tuned1, meanVec_tuned1, stdVec_tuned1] = convert4NSS(result_tuned1);
        [result_tuned2, meanVec_tuned2, stdVec_tuned2] = convert4NSS(result_tuned2);

        % TODO kyokai6以上？
        % 境界ぼかし

        %infos_near = infos(find(infos(:,4)<th1.*ones_),:);
        %sel_near = randperm(size(infos_near, 1));
        %nss_Tt1 = [nss_Tt1 result_tuned1(infos_near(sel_near(1), 2), infos_near(sel_near(1), 1))];
        %nss_Tt2 = [nss_Tt2 result_tuned2(infos_near(sel_near(1), 2), infos_near(sel_near(1), 1))];
        %nss_Tf = [nss_Tf result_flat(infos_near(sel_near(1), 2), infos_near(sel_near(1), 1))];

        nss_Tt0 = [nss_Tt0 result_tuned0(ny_, nx_)];
        nss_Tt1 = [nss_Tt1 result_tuned1(ny_, nx_)];
        nss_Tt2 = [nss_Tt2 result_tuned2(ny_, nx_)];
        nss_Tf = [nss_Tf result_flat(ny_, nx_)];
        % fprintf('img:%d, sub:%d, i:%d\n', imgidx, sub, i);
    end
    
    if(size(nss_Tf, 1) ~= 0)
        %fprintf('%f,%f,%f\n', mean(nss_Tt1), mean(nss_Tt2), mean(nss_Tf));
        %fprintf(fid, '%f,%f,%f\n', mean(nss_Tt1), mean(nss_Tt2), mean(nss_Tf));
    end

    NSS_tuned0 =[NSS_tuned0 mean(nss_Tt0)];
    NSS_tuned1 =[NSS_tuned1 mean(nss_Tt1)];
    NSS_tuned2 =[NSS_tuned2 mean(nss_Tt2)];
    NSS_flat =[NSS_flat mean(nss_Tf)];

end

%fclose(fid);
fprintf([num2str(toc), ' seconds \n']);