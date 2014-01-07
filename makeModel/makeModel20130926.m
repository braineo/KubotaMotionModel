%% Kubota model motion version code
% Divide into 3 regions
% Angle disabled

clear all
clearvars -EXCEPT Info EXPALLFixations ALLFeatures faceFeatures sampleinfo sampleinfoStat
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
opt.n_order_fromfirst = 1;
opt.thresholdLengthType = 's_uni'; % how threshold is determined
opt.n_region = 3; % region number
opt.enable_angle = 0;
opt.featNumber = 15; % feature numbers
opt.positiveSize = 0;
opt.negativeSize = 0;
opt.subjectNumber = 5;
opt.stimuliNumber = 434;

%% ----------------- SETTING -----------------------------
fprintf([num2str(toc), ' seconds \n']);

info.opt = opt;

for subjecti = 1:opt.subjectNumber
    
    fprintf('\n\n========================================================= \n Current test subject: #%02d\n', subjecti);
    RET = {};
    [sampleinfo,opt] = makeSampleInfo(opt,EXPALLFixations,subjecti);
    sampleinfoStat = makeSampleStat(sampleinfo,subjecti);
    [RET.mInfo_tune, RET.mNSS_tune, RET.opt_ret] = calcuModel20130926(opt, EXPALLFixations, ALLFeatures, sampleinfo,sampleinfoStat, subjecti);
    EXP_INDV_REGION_NOANGLE_ms6{subjecti} = RET;
    clear opt RET
    
end

info.end_time = datestr(now,'dd-mmm-yyyy HH:MM:SS')
savefile = sprintf('../Output/model0926_%d%d_%s.mat',modelType(1),modelType(2), info.time_stamp);
save(savefile,'EXP_INDV_REGION_NOANGLE_ms6','info','-v7.3');
