%%%%%%%%%%%%%%%%%% Change parameter here %%%%%%%%%%%%%%%%%%%
stimfolder = '../../../dataset/videoDataset/footage_frame/footage_001_new/';% path to your stimuli
savefile = 'footage001.mat'; %for free viewing task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
files=dir(fullfile(stimfolder,'*.jpg'));
[filenames{1:size(files,1)}] = deal(files.name);

ALLFeatures = {};
motinfo = []; % information about the previous frame, blank for the first frame
for i = 1: length(filenames)
    Feature = {};
    Feature.filename = filenames{i};

    fprintf('* %s\n', Feature.filename);

    %graphbase
    params = makeGBVSParams;
    params.channels = 'CIOFM';
    params.salmapmaxsize = 48;
    out = gbvs(strcat(stimfolder, Feature.filename),params);

    graphbase = {};
    graphbase.master_map = out.master_map;
    graphbase.top_level_feat_maps = out.top_level_feat_maps;
    graphbase.map_types = out.map_types;
    %graphbase.intermed_maps = out.intermed_maps;
    graphbase.scale_maps = out.scale_maps;
    graphbase.paramsUsed = out.paramsUsed;
    Feature.graphbase = graphbase;

    %ittikoch
    params = makeGBVSParams;
    params.channels = 'CIOFM';
    params.salmapmaxsize = 48;
    params.activationType = 2;
    params.normalizeTopChannelMaps = 1;
    params.ittiDeltaLevels = [2 3];
    params.useIttiKochInsteadOfGBVS = 1;
    
    [out,motinfo] = gbvs(strcat(stimfolder, Feature.filename),params, motinfo);

    ittikoch = {};
    ittikoch.master_map = out.master_map;
    ittikoch.top_level_feat_maps = out.top_level_feat_maps;
    ittikoch.map_types = out.map_types;
    %ittikoch.intermed_maps = out.intermed_maps;
    ittikoch.scale_maps = out.scale_maps;
    ittikoch.paramsUsed = out.paramsUsed;
    Feature.ittikoch = ittikoch;

    ALLFeatures{i} = Feature;
end


save(savefile, 'ALLFeatures', '-v7.3');
