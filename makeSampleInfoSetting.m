%% Return all positive and negative sample information in mat file

% clear all
info = {};
info.time_stamp = datestr(now,'yyyymmddHHMM');
info.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');

%% ----------------- TEMPLATE -----------------------------
fprintf('Load Fixations,...'); tic
% load('../Data/EXPALLFixationsPref.mat'); % EXPALLFixations

opt = {};
opt.time_stamp = info.time_stamp;
opt.IMGS = './final_resize';
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

opt.rand_param = {};
%opt.discard_short_saccade = tool.get_distance(2);
opt.discard_short_saccade = -1;

opt.thresholdLength = {};
opt.thresholdAngle = {};
opt.thresholdAngleInit = {5, 8, 11, 14, 20, 57};
%opt.thresholdAngleInit = {6, 9, 12, 16, 22, 80};

opt_base = opt;
clear opt
%% ----------------- TEMPLATE -----------------------------

%% ----------------- SETTING -----------------------------
opt = opt_base;
opt.posisize = 50000;
opt.ngrate = 20;
opt.n_trial = 20;
% opt.n_order_fromfirst = 5;
opt.thresholdLengthType = 's_uni'; %
opt.allAreTrainingSample = 1;
opt_base = opt;
clear opt
%% ----------------- SETTING -----------------------------

info.opt_base = opt_base;
for saccadeOrder = 1:1
    
    opt = opt_base;
    opt.n_order_fromfirst = saccadeOrder;
    opt.n_region = 3;
    opt.enable_angle = 0;

    [sampleinfo, Info] = makeSampleInfo(opt, EXPALLFixations);
    savefile = sprintf('../Output/sampleInfoSaccade%d_3Region.mat',saccadeOrder);
% save(savefile,'sampleinfo','Info','-v7.3');
end
info.end_time = datestr(now,'dd-mmm-yyyy HH:MM:SS')