image = imread('text1.jpg');
%image = imread('text2.png');
image = im2double(rgb2gray(image));

[h, w, channels] = size(image);

patchAmount = 4;
patchSize = 9;
wPatch = randi([1, w-patchSize], 1, 4);
hPatch = randi([1, h-patchSize], 1, 4);
patchs = zeros(patchSize, patchSize, patchAmount);


for i = 1:patchAmount
    patchs(:, :, i) = image(wPatch(i):wPatch(i)+patchSize-1, hPatch(i):hPatch(i)+patchSize-1);
end



ssd1 = SSD(image, patchs(:, :, 1));
ssd2 = SSD2(image, patchs(:, :, 1));
ssd3 = SSD3(image, patchs(:, :, 1));
sad = SAD(image, patchs(:, :, 1));
gwssd = GWSSD(image, patchs(:, :, 1));
ncc = NCC(image, patchs(:, :, 1));

blank = ones(w, h);
patchImage = ones(w, h);
patchImage(10:18, 11:19) = patchs(:, :, 1);
patchImage(10:18, 21:29) = patchs(:, :, 2);
patchImage(10:18, 31:39) = patchs(:, :, 3);
patchImage(10:18, 41:49) = patchs(:, :, 4);

outputImage = [image ssd1 ssd2 ssd3; patchImage ncc sad gwssd];

close all;
figure;
imshow(outputImage);

function output = SSD(image, patch)
    patch = reshape(patch, size(patch, 1), size(patch, 2));
    
    [h, w] = size(image);
    [hPatch, wPatch] = size(patch);
    
    output = zeros(w, h);
    
    for m = 1:h-hPatch
        for n = 1:w-wPatch
            for k = 1:hPatch
                for l = 1:wPatch
                    output(m, n) = output(m,n) + (patch(k,l) - image(m+k, n+l))^2;
                end
            end
            
        end
    end
    
    output = output / (hPatch * wPatch);
end

function output = SSD2(image, patch)
    patch = reshape(patch, size(patch, 1), size(patch, 2));
    
    [h, w] = size(image);
    [hPatch, wPatch] = size(patch);
    
    output = zeros(w, h);
    
    for m = 1:h-hPatch
        for n = 1:w-wPatch            
            output(m,n) = sum(sum((patch - image(m:m+hPatch-1, n:n+wPatch-1)).^2));            
        end
    end
    
    output = output / (hPatch * wPatch);
end

function output = SSD3(image, patch)
    patch = reshape(patch, size(patch, 1), size(patch, 2));
    
    [h, w] = size(image);
    [hPatch, wPatch] = size(patch);
    
    output = zeros(w, h);
    
    for m = 1:h-hPatch
        for n = 1:w-wPatch            
            output(m,n) = sum(sum((patch - image(m:m+hPatch-1, n:n+wPatch-1)).^2));            
        end
    end
    
    output = 1 - sqrt(output);
end

function output = SAD(image, patch)
    patch = reshape(patch, size(patch, 1), size(patch, 2));
    
    [h, w] = size(image);
    [hPatch, wPatch] = size(patch);
    
    output = zeros(w, h);
    
    for m = 1:h-hPatch
        for n = 1:w-wPatch            
            output(m,n) = sum(sum((patch - image(m:m+hPatch-1, n:n+wPatch-1))));            
        end
    end
    
    output = output / (hPatch * wPatch);
end

function output = GWSSD(image, patch)
    patch = reshape(patch, size(patch, 1), size(patch, 2));
    
    [h, w] = size(image);
    [hPatch, wPatch] = size(patch);
    
    output = zeros(w, h);
    kernel = fspecial('gaussian', [hPatch, wPatch], 2);
    
    for m = 1:h-hPatch
        for n = 1:w-wPatch            
            output(m,n) = sum(sum(kernel .* (patch - image(m:m+hPatch-1, n:n+wPatch-1)).^2));            
        end
    end
end

function output = NCC(image, patch)
    patch = reshape(patch, size(patch, 1), size(patch, 2));
    
    [h, w] = size(image);
    [hPatch, wPatch] = size(patch);
    
    output = zeros(w, h);
    
    filterMean = mean2(patch);
    filterCross = sum(sum(patch - filterMean));
    filterCrossSquared = sum(sum((patch - filterMean).^2));
    
    for m = 1:h-hPatch
        for n = 1:w-wPatch
            
            imageMean = mean2(image(m:m+hPatch-1, n+wPatch-1));
            imageCross = sum(sum(image(m:m+hPatch-1, n+wPatch-1) - imageMean));
            imageCrossSquared = sum(sum((image(m:m+hPatch-1, n+wPatch-1) - imageMean).^2));
            
            
            output(m, n) = sum(filterCross * imageCross) / sqrt(filterCrossSquared * imageCrossSquared);
            
            
            
        end
    end
    
    %output = 1 - output;       
end