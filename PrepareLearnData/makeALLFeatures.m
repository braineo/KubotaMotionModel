%%%%%%%%%%%%%%%%%% Change parameter here %%%%%%%%%%%%%%%%%%%

outputPath = '/Volumes/davinci/MATLAB/KubotaMotionModel/Data/featureMaps/'; %for free viewing task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameFolder = csvimport('frameFolder.csv');
motinfo = []; % information about the previous frame, blank for the first frame

for i = 1: size(frameFolder,1)
    
    stimfolder = frameFolder{i,1};% path to your stimuli
    files=dir(fullfile(stimfolder,'*.jpg'));
    [filenames{1:size(files,1)}] = deal(files.name);
    footageFeatures = {};
    for j = 1 : length(filenames)
        
        Feature = {};
        Feature.filename = filenames{j};
        fprintf('* %s %s\n', stimfolder, Feature.filename);
        %graphbase
        params = makeGBVSParams;
        params.channels = 'CIOFM';
        params.salmapmaxsize = 48;
        [out,motinfo] = gbvs(strcat(stimfolder, Feature.filename),params, motinfo);

        graphbase = {};
        graphbase.master_map = out.master_map;
        graphbase.top_level_feat_maps = out.top_level_feat_maps;
        graphbase.map_types = out.map_types;
        %graphbase.intermed_maps = out.intermed_maps;
        graphbase.scale_maps = out.scale_maps;
        graphbase.paramsUsed = out.paramsUsed;
        Feature.graphbase = graphbase;
        footageFeatures{j} = Feature;
    end
    savefile = sprintf('%s%s',outputPath, frameFolder{i,2});
    save(savefile, 'footageFeatures', '-v7.3');
end



