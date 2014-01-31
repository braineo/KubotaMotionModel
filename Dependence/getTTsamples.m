%% Gernerate learning and testing saccade samples with random factor
% get Training fixation
% This version only apply for motion model!
function sample_saccade = getTTsamples(opt, allFixations, subjecti, videoi)

    sample_saccade = zeros(100000,9);
    testingsamles = {};
    c_sample_saccade=0;
    if(isempty(allFixations{subjecti}{videoi}))
        sample_saccade = zeros(1,9);
        return
    else
    fix_length = size(allFixations{subjecti}{videoi}.medianXY, 1);
    
    if(fix_length < 2)
        sample_saccade = zeros(1,9);
        return
    end

    for fixIndex=2:fix_length
        valid_flag = 1;

        if(allFixations{subjecti}{videoi}.medianXY(fixIndex, 1) < 0 || allFixations{subjecti}{videoi}.medianXY(fixIndex, 2) < 0 || ...
           allFixations{subjecti}{videoi}.medianXY(fixIndex, 1) >= opt.width || allFixations{subjecti}{videoi}.medianXY(fixIndex, 2) >= opt.height)
            valid_flag = 0;
        end
        t_px = allFixations{subjecti}{videoi}.medianXY(fixIndex-1, 1)/opt.minimize_scale; % previous fixation
        t_py = allFixations{subjecti}{videoi}.medianXY(fixIndex-1, 2)/opt.minimize_scale;
        t_nx = allFixations{subjecti}{videoi}.medianXY(fixIndex, 1)/opt.minimize_scale; % current fixation
        t_ny = allFixations{subjecti}{videoi}.medianXY(fixIndex, 2)/opt.minimize_scale;
        t_dis = norm([t_px-t_nx t_py-t_ny]);
        
        startM = allFixations{subjecti}{videoi}.start(fixIndex);
        endM = allFixations{subjecti}{videoi}.end(fixIndex);
        timeTag = ceil((startM + endM)/2 * opt.frameRate/opt.sampleRate);
    

        if((opt.discard_short_saccade > 0) && (t_dis < opt.discard_short_saccade))
            valid_flag = 0; % 1 is valid
        end

        c_sample_saccade = c_sample_saccade + 1;
        sample_saccade(c_sample_saccade,:) = [videoi fixIndex-1 t_px t_py t_nx t_ny t_dis valid_flag timeTag];

        %fprintf(fid, '%f,%d,%d,%f\n', valid_flag, videoi, i-1, tool.get_angle(t_dis));
        clear t_px t_py t_nx t_ny t_dis
    end

    clear fix_length sacinfo_c
    
    sample_saccade = sample_saccade(1:c_sample_saccade,:);

    %fclose(fid);
    end
    fprintf('training fixation: %d\n',...
            c_sample_saccade);
