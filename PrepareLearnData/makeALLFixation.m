% generate fixations (.m) from raw fixations (csv file)
%%%%%%%%%%%%%%%%%%%% Change Parameters here %%%%%%%%%%%%%%%%%%%%%%%%%%%
datafolder = '../Data/rawFixation/';
savefile = '../Data/allFixations.mat';
datasetSize = 434;
testSubjectNumber = 25;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allFixations = {};


for subject = 1:testSubjectNumber
    for imgidx = 1:datasetSize
        datafile = sprintf('%s%02d%03d.csv', datafolder, subject, imgidx);
        % fprintf('%s\n',datafile);
        eyedata = load(datafile);
        if(isempty(eyedata))
            fprintf('%s\n',datafile);
        else
        [data,Fix,Sac] = getFixations(eyedata);
        allFixations{subject}{imgidx}=Fix;
        end
    end
end

save(savefile, 'allFixations', '-v7.3');
