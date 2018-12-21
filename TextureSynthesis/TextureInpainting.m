%% Synthesis function
function textureSynth = TextureInpainting(textureOriginal, seedSize)
    % Progressive display initialization
    close all;
    figure;
    ss = get(0, 'Screensize');
    set(gcf, 'ToolBar', 'none');
    set(gcf, 'Position', [ss(3)/4 ss(4)/4 ss(3)/2 ss(4)/2]);
    set(gca, 'Position', [0 0 1 1]);
    
    % Initialization
    [h, w, c] = size(textureOriginal);
    halfSeed = floor(seedSize / 2.0);
    
    % Set T as starting image
    textureSynth = textureOriginal;
    
    % Generate mask by using every pixel that is black or almost black in
    % the original image
    mask = textureOriginal;
    mask(mask > 0.1) = 1;
    mask(mask <= 0.1) = 0;
    mask = mask(:, :, 1);

    % Pad image
    paddedOriginal = padarray(textureOriginal, [halfSeed halfSeed], 'both');
    
    % Generate Gaussian kernel
    gaussianKernel = fspecial('gaussian', [seedSize, seedSize], 2);
    
    % Get all patches from original texture beforehand
    origPatchs = zeros(h, w, seedSize, seedSize, c);
    for m = 1:h
        for n = 1:w
            if(mask(m, n) == 1) % if it is part of the actual texture
                origPatchs(m, n, :, :, :) = reshape(paddedOriginal(m:m+halfSeed*2, n:n+halfSeed*2, :), 1, 1, seedSize, seedSize, c);
            else  % fill hole with white to avoid it being used for further hole filling
                origPatchs(m, n, :, :, :) = ones(1, 1, seedSize, seedSize, c);
            end
        end
    end
    
    % While T is not filled
    while sum(sum(textureSynth(1+halfSeed:h-halfSeed, 1+halfSeed:w-halfSeed) == 0)) > 0
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
            if yMin >= 1 && yMax <= h && xMin >= 1 && xMax <= w
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
        imshow(textureSynth(1+halfSeed:h-halfSeed, 1+halfSeed:w-halfSeed, :));
        drawnow;
    end
    
    % Remove zero padding
    textureSynth = textureSynth(1+halfSeed:h-halfSeed, 1+halfSeed:w-halfSeed, :);
end