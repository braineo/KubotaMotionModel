% settings

sampleRate = 120; %Hz
frameRate = 24;
M = 1080;
N = 1920;
load('../Data/allFixations.mat')
saliencyMapPath = '../Data/featureMaps/';

% create index -> filename mapping
hashKeyValue = csvimport('footageNumMap.csv','noHeader',true);
key = hashKeyValue(:,2);
value = hashKeyValue(:,1);
numHash = containers.Map(key, value);

% work begin
score = zeros(1,10);
for videoi = 1:120
    for subjecti = 1:1
        for timei = 1:10
            fixIndex = find(allFixations{subjecti}{videoi}.end < sampleRate*timei & ...
                            allFixations{subjecti}{videoi}.end > sampleRate*(timei-1));
            startM = allFixations{subjecti}{videoi}.start(fixIndex);
            endM = allFixations{subjecti}{videoi}.end(fixIndex);
            videoFrameIndex = ceil((startM + endM)/2 * frameRate/sampleRate);
            fixation = allFixations{subjecti}{videoi}.medianXY(fixIndex,:);
            fixationLib = [videoFrameIndex' fixation];

            %load saliency map
            fileName = numHash(videoi);
            saliencyFile = sprintf('%s%s%s', saliencyMapPath, fileName, '.mat');
            load(saliencyFile);

            for i = 1:size(fixationLib,1)
                saliencyMap = imresize(footageFeatures{fixationLib(i,1)}.graphbase.master_map, [M N], 'bilinear');
                x = ceil(fixationLib(i,3));
                y = ceil(fixationLib(i,2));
                if( x > 1 && x <=1920 && y > 1 && y <= 1080)
                    score(timei) = score(timei) + saliencyMap(y,x);
                end
            end
        end
    end
end