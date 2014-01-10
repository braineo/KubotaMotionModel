%% Kubota model motion version code
% Divide into 3 regions
% Angle disabled

%clear all
info = {};
info.time_stamp = datestr(now,'yyyymmddHHMM');
info.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');

%% ----------------- TEMPLATE -----------------------------
fprintf('Setting up model options...'); tic

opt = {};

opt.time_stamp = info.time_stamp;
opt.minimize_scale = 6;
opt.width = 1920;
opt.height = 1080;
opt.M = round(opt.height/opt.minimize_scale);
opt.N = round(opt.width/opt.minimize_scale);
M = opt.M;
N = opt.N;
tool = toolFunc(opt);

opt.th_near = tool.get_distance(1.0);
opt.th_far = tool.get_distance(4.0);
opt.u_sigma = tool.get_distance(1.0);

%opt.discard_short_saccade = tool.get_distance(2);
opt.discard_short_saccade = -1;

opt.thresholdLength = {};
opt.thresholdAngle = {};
opt.thresholdAngleInit = {5, 8, 11, 14, 20, 57};

%% ----------------- SETTING -----------------------------
opt.featureMapPath = '../Data/featureMaps/';
opt.n_order_fromfirst = 5; % from the first to nth saccade are used
opt.thresholdLengthType = 's_uni'; % how threshold is determined
opt.n_region = 3; % region number
opt.enable_angle = 0;
opt.featNumber = 15; % feature numbers in 1 region
% opt.positiveSize = 0;
% opt.negativeSize = 0;
opt.subjectNumber = 1; % number of test subjects
opt.stimuliNumber = 434; % number of stimuli
opt.frameRate = 24; % video frame rate
opt.sampleRate = 120; % eye tracker sample rate
opt.posSampleSizeAll = 400000; % size of positive sample for 1 test subject
opt.negaPosRatio = 10; % ratio of negaSize:posSize
%% ----------------- SETTING -----------------------------
% determine threshold length

load('../data/allFixations.mat');
    for order_fromfirst=1:opt.n_order_fromfirst % to nth saccade
        [thresholdLength, thresholdAngle, n_samples_each_region] = getThresholdLength(order_fromfirst, allFixations, opt);
        opt.thresholdLength{order_fromfirst} = thresholdLength;
        opt.thresholdAngle{order_fromfirst} = thresholdAngle;
        opt.n_samples_each_region{order_fromfirst} = n_samples_each_region;
        clear thresholdLength thresholdAngle n_samples_each_region
    end
 %--------------------------------------------------------
fprintf([num2str(toc), ' seconds \n']);

info.opt = opt;
featureWeight = cell(1, opt.subjectNumber);
for subjecti = 1:opt.subjectNumber
    
    fprintf('\n\n========================================================= \n Current test subject: #%02d\n', subjecti);
    RET = {};
    [RET.mInfo_tune, RET.mNSS_tune, RET.opt_ret] = calcuModel(opt,allFixations, subjecti);
    featureWeight{subjecti} = RET;
    clear opt RET
    
end

info.end_time = datestr(now,'dd-mmm-yyyy HH:MM:SS')
savefile = sprintf('../Output/model_v0_1_%s.mat', info.time_stamp);
save(savefile,'featureWeight','info','-v7.3');
