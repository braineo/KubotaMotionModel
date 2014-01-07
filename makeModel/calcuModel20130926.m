%% Main function of the project, calculating the weights
% return the result of training and NSS score for a single test subject
% Random sampling algorithm: reservoir sampling
% parameter:
% opt_set: Setting up options
% saccadeData: saccade data of 15 subject view 450 pictures
% featureGBVS: GBVS saliency map
% faceFeature: Gaussian face feature
% subjectIndex: ID of test subject

% Try to use all samples for individuals
function  [mInfo_tune, mNSS_tune, opt] = calcuModel20130926(opt_set, featureGBVS, sampleinfo, sampleinfoStat,subjecti)

    opt = opt_set;
    opt.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
    M = opt.M; % original resolution X
    N = opt.N; % original resolution Y
    tool = toolFunc(opt); % return distance on screen by angle? not really understand
    %% initialize settings
    positiveSampleSize = sampleinfoStat{subjecti}.PositiveRegion;
    negativeSampleSize = sampleinfoStat{subjecti}.NegativeRegion;

    order_fromfirst = opt.n_order_fromfirst;

    fprintf('Start Calculation on Subject#%d...\n',subjecti);

    countNearAll = 0;
    countFarAll = 0;
    num_feat_A = 10; %total number of features
    if(opt.enable_angle)
        featurePixelValueNear = zeros(sum(positiveSampleSize), 3*num_feat_A*opt.n_region); % 3 directions, feature numbers, n regions
        featurePixelValueFar = zeros(sum(negativeSampleSize),3*num_feat_A*opt.n_region);
    else
        featurePixelValueNear = zeros(sum(positiveSampleSize), num_feat_A*opt.n_region);
        featurePixelValueFar = zeros(sum(negativeSampleSize),num_feat_A*opt.n_region);
    end

    %% 

    fprintf('Get training sample...\n'); tic
    selectedPositiveSample = [];
    selectedNegativeSample = [];
    for regioni = 1:opt.n_region
        posPointer = 1;
        negPointer = 1;
        allPositiveSampleInRegion = zeros(sampleinfoStat{subjecti}.PositiveRegion(regioni),8);
        allNegativeSampleInRegion = zeros(sampleinfoStat{subjecti}.NegativeRegion(regioni),8);

        for imgidx = opt.trainImgIndex
            if(ismember(imgidx, sampleinfoStat{subjecti}.EmptyCell))
                continue;
            end
            if(~isempty(sampleinfo{subjecti}{imgidx}{1}{regioni}))
                sizePos = size(sampleinfo{subjecti}{imgidx}{1}{regioni},1);
                allPositiveSampleInRegion(posPointer: posPointer+sizePos-1,:) = sampleinfo{subjecti}{imgidx}{1}{regioni};
                posPointer = posPointer + sizePos;
            end
            if(~isempty(sampleinfo{subjecti}{imgidx}{2}{regioni}))
                sizeNeg = size(sampleinfo{subjecti}{imgidx}{2}{regioni},1);
                allNegativeSampleInRegion(negPointer: negPointer+sizeNeg-1,:) = sampleinfo{subjecti}{imgidx}{2}{regioni};
                negPointer = negPointer + sizeNeg;
            end
        end
        
        allPositiveSampleInRegion = allPositiveSampleInRegion(1:posPointer-1,:);
        allNegativeSampleInRegion = allNegativeSampleInRegion(1:negPointer-1,:);
        
        selectedPositiveSample = [selectedPositiveSample;allPositiveSampleInRegion];
        selectedNegativeSample = [selectedNegativeSample;allNegativeSampleInRegion];
    end

    fprintf([num2str(toc), ' seconds \n']);
    fprintf('Creating feature matrix...\n'); tic
    imgUsed = [selectedPositiveSample(:,1) ; selectedNegativeSample(:,1)];
    imgUsed = unique(imgUsed)';

    %% Postive Sample values
    for imgIdx = imgUsed
        % load feature map for a video
        %--wait for construct--%
        
        % reading feature map values
        c = cell(1,3);
        i = cell(1,3);
        o = cell(1,3);
        f = cell(1,3);
        m = cell(1,3);
        
        sfprintf('fetching feature map of video#03d', imgIdx);
        for scaleLeveli = 1: 3
            c{scaleLeveli} = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{1}{scaleLeveli}, [M N], 'bilinear');
            i{scaleLeveli} = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{3}{scaleLeveli}, [M N], 'bilinear');
            o{scaleLeveli} = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{5}{scaleLeveli}, [M N], 'bilinear');
            f{scaleLeveli} = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{2}{scaleLeveli}, [M N], 'bilinear');
            m{scaleLeveli} = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{4}{scaleLeveli}, [M N], 'bilinear');
        end

        posIdx = find(selectedPositiveSample(:,1) == imgIdx)';
        negIdx = find(selectedNegativeSample(:,1) == imgIdx)';

        for i = posIdx
            singleSample = selectedPositiveSample(i,:);
            angleIndex = singleSample(8);
            regioni = singleSample(6);
            countNearAll = countNearAll + 1;

            tmpX = singleSample(3);
            tmpY = singleSample(2);
            singleFeature = [c{1}(tmpX,tmpY) c{2}(tmpX,tmpY) c{3}(tmpX,tmpY)...
                             i{1}(tmpX,tmpY) i{2}(tmpX,tmpY) i{3}(tmpX,tmpY)...
                             o{1}(tmpX,tmpY) o{2}(tmpX,tmpY) o{3}(tmpX,tmpY)...
                             f{1}(tmpX,tmpY) f{2}(tmpX,tmpY) f{3}(tmpX,tmpY)...
                             m{1}(tmpX,tmpY) m{2}(tmpX,tmpY) m{3}(tmpX,tmpY)];
            if(opt.enable_angle)
                featurePixelValueNear(countNearAll,num_feat_A*3*(regioni-1)+(angleIndex-1)*num_feat_A+1:num_feat_A*3*(regioni-1)+angleIndex*num_feat_A)=singleFeature(:);
            else
                featurePixelValueNear(countNearAll,num_feat_A*(regioni-1)+1:num_feat_A*regioni)=singleFeature(:);
            end
        end
        
        clear tmpX tmpY
        %% Negative Samples
        for i = negIdx
            singleSample = selectedNegativeSample(i,:);
            angleIndex = singleSample(8);
            regioni = singleSample(6);
            countFarAll = countFarAll + 1;
            
            tmpX = singleSample(3);
            tmpY = singleSample(2);
            singleFeature = [c{1}(tmpX,tmpY) c{2}(tmpX,tmpY) c{3}(tmpX,tmpY)...
                             i{1}(tmpX,tmpY) i{2}(tmpX,tmpY) i{3}(tmpX,tmpY)...
                             o{1}(tmpX,tmpY) o{2}(tmpX,tmpY) o{3}(tmpX,tmpY)...
                             f{1}(tmpX,tmpY) f{2}(tmpX,tmpY) f{3}(tmpX,tmpY)...
                             m{1}(tmpX,tmpY) m{2}(tmpX,tmpY) m{3}(tmpX,tmpY)];
            if(opt.enable_angle)
                featurePixelValueFar(countFarAll,num_feat_A*3*(regioni-1)+(angleIndex-1)*num_feat_A+1:num_feat_A*3*(regioni-1)+angleIndex*num_feat_A)=singleFeature(:);
            else
                featurePixelValueFar(countFarAll,num_feat_A*(regioni-1)+1:num_feat_A*regioni)=singleFeature(:);
            end
        end
    end
    fprintf([num2str(toc), ' seconds \n']);

    %%  start to train

    featureMat = [featurePixelValueNear(1:countNearAll,:); featurePixelValueFar(1:countFarAll,:)];

    labelMat = [ones(countNearAll, 1); zeros(countFarAll, 1)];

    fprintf('Training...\n'); tic
    info_tune = {};

    fprintf('|tune|');
    [m_,n_] = size(featureMat);
    [info_tune.weight,info_tune.resnorm,info_tune.residual,info_tune.exitflag,info_tune.output,info_tune.lambda]  =  lsqlin(featureMat, labelMat,-eye(n_,n_),zeros(n_,1));
    fprintf([num2str(toc), ' seconds \n']);

    clear featureMat labelMat        
    NSS_tune = [];
    mInfo_tune = info_tune;
    mNSS_tune = NSS_tune;
    clear info_tune


    % opt.end_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
    % time_stamp = datestr(now,'yyyymmddHHMMSS');
    % savefile = sprintf('../Output/storage/EXP_%s_angle%dregion%dTestSub%d_%s.mat', ...
    %                    opt.time_stamp, opt.enable_angle, opt.n_region, subjectIndex, time_stamp);
    % save(savefile,'opt','mInfo_tune','-v7.3');