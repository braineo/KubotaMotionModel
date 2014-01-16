function [featurePixelValueNear, featurePixelValueFar] = getFeatureSample(opt, sampleinfo, videoi)
    positiveSample = sampleinfo{1};
    negativeSample = datasample(sampleinfo{2}, size(positiveSample,1)*opt.negaPosRatio);
    featureMapFile = sprintf('%s%03d.mat', opt.featureMapPath, videoi);
    % load feature map for a video
    load(featureMapFile);
    
    % 1. videoi, 2.X, 3. Y, 4. Region number, 5. Angle(index) 6. timeTag (frame number)
    timeTag = unique(positiveSample(:,5));
    num_feat_A = opt.featNumber;
    % Allocate storage
    if(opt.enable_angle)
        featurePixelValueNear = zeros(size(positiveSample, 1), 3*num_feat_A*opt.n_region); % 3 directions, feature numbers, n regions
        featurePixelValueFar = zeros(size(negativeSample, 1),3*num_feat_A*opt.n_region);
    else
        featurePixelValueNear = zeros(size(positiveSample, 1), num_feat_A*opt.n_region);
        featurePixelValueFar = zeros(size(negativeSample,1),num_feat_A*opt.n_region);
    end
    
    M = opt.M;
    N = opt.N;
    countNearAll = 0;
    countFarAll = 0;
    for framei = timeTag'
        
        if(framei > opt.allFrameNumber)
            continue;
        else
            % reading feature map values
            c = cell(1,3);
            i = cell(1,3);
            o = cell(1,3);
            f = cell(1,3);
            m = cell(1,3);
            
            % fprintf('fetching feature map of frame#%03d\n', framei);
            for scaleLeveli = 1: 3
                c{scaleLeveli} = imresize(footageFeatures{framei}.graphbase.scale_maps{1}{scaleLeveli}, [M N], 'bilinear');
                i{scaleLeveli} = imresize(footageFeatures{framei}.graphbase.scale_maps{3}{scaleLeveli}, [M N], 'bilinear');
                o{scaleLeveli} = imresize(footageFeatures{framei}.graphbase.scale_maps{5}{scaleLeveli}, [M N], 'bilinear');
                f{scaleLeveli} = imresize(footageFeatures{framei}.graphbase.scale_maps{2}{scaleLeveli}, [M N], 'bilinear');
                m{scaleLeveli} = imresize(footageFeatures{framei}.graphbase.scale_maps{4}{scaleLeveli}, [M N], 'bilinear');
            end

            posIdx = find(positiveSample(:,5) == framei)';
            negIdx = find(negativeSample(:,5) == framei)';
            %% Postive Sample values
            for j = posIdx
                singleSample = positiveSample(j,:);
                angleIndex = singleSample(4);
                regioni = singleSample(3);
                countNearAll = countNearAll + 1;

                tmpX = singleSample(2); % actually is Y
                tmpY = singleSample(1); % acutally is X
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
            for j = negIdx
                singleSample = negativeSample(j,:);
                angleIndex = singleSample(4);
                regioni = singleSample(3);
                countFarAll = countFarAll + 1;
                
                tmpX = singleSample(2);
                tmpY = singleSample(1);
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
    end
    fprintf('pos: %d, neg: %d\n', countNearAll, countFarAll)