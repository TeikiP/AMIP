%% Synthesis function
function textureSynth = TextureGrowing(textureOriginal, seedSize, enlargeFactor)
    % Progressive display initialization
    close all;
    figure;
    ss = get(0, 'Screensize');
    set(gcf, 'ToolBar', 'none');
    set(gcf, 'Position', [ss(3)/4 ss(4)/4 ss(3)/2 ss(4)/2]);
    set(gca, 'Position', [0 0 1 1]);
    
    % Initialization (change output size here)
    [h, w, c] = size(textureOriginal);
    hNew = h * enlargeFactor;
    wNew = w * enlargeFactor;
    
    % Set T(x,y)=0 for all pixels (x,y)
    textureSynth = zeros(hNew, wNew, c);
    
    % Randomly select a x-by-x seed s from S
    seed = getRandomPatch(textureOriginal, seedSize);
    
    % Find the center of T
    yCenter = floor(hNew/2);
    xCenter = floor(wNew/2);
    halfSeed = floor(seedSize / 2.0);
    
    % Copy s at the center of T    
    textureSynth(yCenter-halfSeed:yCenter+halfSeed, xCenter-halfSeed:xCenter+halfSeed, :) = seed;
    textureSynth = padarray(textureSynth, [halfSeed halfSeed], 'both');
    [hNew, wNew, c] = size(textureSynth);
    
    % Create mask M: M(x,y)=0 if T(x,y)=0, M(x,y)=1 otherwise
    mask = zeros(hNew, wNew);
    mask(yCenter-halfSeed:yCenter+halfSeed, xCenter-halfSeed:xCenter+halfSeed) = ones(seedSize);
    mask = padarray(mask, [halfSeed halfSeed], 'both');
    
    % Pad image
    paddedOriginal = padarray(textureOriginal, [halfSeed halfSeed], 'both');
    
    % Generate Gaussian kernel
    gaussianKernel = fspecial('gaussian', [seedSize, seedSize], 2);
    
    % Get all patches from original texture beforehand
    origPatchs = zeros(h, w, seedSize, seedSize, c);
    for m = 1:h
        for n = 1:w
            origPatchs(m, n, :, :, :) = reshape(paddedOriginal(m:m+halfSeed*2, n:n+halfSeed*2, :), 1, 1, seedSize, seedSize, c);
        end
    end
    
    % While T is not filled
    while sum(sum(textureSynth(1+halfSeed:hNew-halfSeed, 1+halfSeed:wNew-halfSeed) == 0)) > 0
        % Find next layer L = dilate(M) - M
        layer = imdilate(mask, strel('square', 3)) - mask;
        
        % For each pixel (x,y) such that L(x,y) = 1:
        [yPatch, xPatch] = find(layer == 1);

        % For each pixel (i,j) in S: compute SSD between patch in S centered at (i,j) and patch in T centered at (x,y) (only for known pixels)
        for i = 1:size(xPatch, 1)
            % Get patch coordinates
            yMin = yPatch(i) - halfSeed;
            yMax = yPatch(i) + halfSeed;
            xMin = xPatch(i) - halfSeed;
            xMax = xPatch(i) + halfSeed;
            
            % Avoid border overflow
            if yMin >= 1 && yMax <= hNew && xMin >= 1 && xMax <= wNew
                % Preallocate
                ssd = zeros(h, w);

                % Get centered patches
                maskPatch = mask(yMin:yMax, xMin:xMax);
                synthPatch = textureSynth(yMin:yMax, xMin:xMax, :);

                % GWSSD
                for m = 1:h
                    for n = 1:w
                        origPatch = reshape(origPatchs(m, n, :, :, :), seedSize, seedSize, c);
                        ssd(m, n) = sum(sum(sum(gaussianKernel .* maskPatch .* (synthPatch - origPatch) .^ 2)));
                   end
                end

                % Find the best matching patch p
                bestPatch = min(min(ssd));

                % Keep all patches such that: SSD(T(x,y),S(i,j)) < (1+epsilon) SSD(T(x,y),p)
                eps = 0.1;
                [yCandidates, xCandidates] = find(ssd <= (1+eps) * bestPatch);

                % Pick randomly one of those (i',j')
                randomSelector = randi(size(yCandidates, 1));

                % Copy: T(x,y) = S(i',j')
                textureSynth(yPatch(i), xPatch(i), :) = textureOriginal(yCandidates(randomSelector), xCandidates(randomSelector), :);

                % Set M(x,y)=1
                mask(yPatch(i), xPatch(i)) = 1;
            end
        end

        % Progression display
        cla reset;
        imshow(textureSynth(1+halfSeed:hNew-halfSeed, 1+halfSeed:wNew-halfSeed, :));
        drawnow;
        
    end
    
    % Remove zero padding
    textureSynth = textureSynth(1+halfSeed:hNew-halfSeed, 1+halfSeed:wNew-halfSeed, :);
    
end

%% Find a random patch from texture
function patch = getRandomPatch(texture, seedSize)
    % Texture size
    [h, w, c] = size(texture);
    
    % Patch size
    halfSeed = floor(seedSize / 2.0);
    
    % Patch location
    yPatch = randi([1+halfSeed, h-halfSeed]);
    xPatch = randi([1+halfSeed, w-halfSeed]);
    
    % Get patch
    patch = texture(yPatch-halfSeed:yPatch+halfSeed, xPatch-halfSeed:xPatch+halfSeed, :);
end