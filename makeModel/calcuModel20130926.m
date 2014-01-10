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
function  [mInfo_tune, mNSS_tune, opt] = calcuModel20130926(opt_set, featureGBVS, sampleinfoStat, subjecti)

    opt = opt_set;
    opt.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
    M = opt.M; % original resolution X
    N = opt.N; % original resolution Y
    tool = toolFunc(opt); % return distance on screen by angle? not really understand
    %% initialize training matrix
    fprintf('Start Calculation on Subject#%d...\n',subjecti);

    num_feat_A = opt.featNumber; %total number of features
    if(opt.enable_angle)
        featurePixelValueNear = zeros(400000, 3*num_feat_A*opt.n_region); % 3 directions, feature numbers, n regions
        featurePixelValueFar = zeros(200000000,3*num_feat_A*opt.n_region);
    else
        featurePixelValueNear = zeros(400000, num_feat_A*opt.n_region);
        featurePixelValueFar = zeros(200000000,num_feat_A*opt.n_region);
    end
    
    %% 

    fprintf('Get training sample...\n');
    positiveSample = [];
    negativeSample = [];
    
    countNearAll = 0;
    countFarAll = 0;
    
    tic
    for videoi = 1:opt.stimuliNumber
        % postive and negative sample (pixel position)
        sampleinfo = makeSampleInfo(opt, EXPALLFixations, subjecti, videoi);
        

    
        fprintf('Creating feature matrix...\n'); 


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