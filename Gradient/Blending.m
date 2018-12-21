%% Add files to current session
filename = mfilename;
fullpath = mfilename('fullpath');
directory = char(extractBefore(fullpath, length(fullpath)-length(filename)));
addpath(directory, strcat(directory, '/Blending'), strcat(directory, '/Fusion'));

%% Read image
image1 = im2double(imread('orchid.jpg'));
image2 = im2double(imread('violet.jpg'));
imageM = im2double(imread('orchid_mask.bmp'));
[h, w, c] = size(image1);

%% Progressive display initialization
close all;
figure;
ss = get(0, 'Screensize');
set(gcf, 'ToolBar', 'none');
set(gcf, 'Position', [ss(3)/4 ss(4)/4 ss(3)/2 ss(4)/2]);
set(gca, 'Position', [0 0 1 1]);

%% Downsampling
i = 1;
sigma = 3;
while (h > 1 && w > 1)
    %% Image 1
    blur1 = imgaussfilt(image1, sigma);
    gaussian1{i} = image1;
    laplacian1{i} = image1 - blur1;
    image1 = imresize(blur1, 0.5);
    
    %% Image 2
    blur2 = imgaussfilt(image2, sigma);
    gaussian2{i} = image2;
    laplacian2{i} = image2 - blur2;
    image2 = imresize(blur2, 0.5);

    %% Mask
    imageM = imgaussfilt(imageM, sigma);
    mask{i} = imageM;
    imageM = imresize(imageM, 0.5);    
    [h, w, c] = size(imageM);
    i = i + 1;
    
    %% Progressive display
    cla reset;
    rgbMask = cat(3, mask{i-1}, mask{i-1}, mask{i-1});
    imshow([gaussian1{i-1} rgbMask gaussian2{i-1}; laplacian1{i-1} rgbMask laplacian2{i-1}]);
    drawnow;
    %pause(1);
end

%% Restructuring
laplacian1 = transpose(laplacian1);
laplacian2 = transpose(laplacian2);

gaussian1 = transpose(gaussian1);
gaussian2 = transpose(gaussian2);

mask = transpose(mask);

imageF1 = gaussian1{i-1} .* mask{i-1} + gaussian2{i-1} .* (1- mask{i-1});
imageF2 = gaussian2{i-1} .* mask{i-1} + gaussian1{i-1} .* (1- mask{i-1});

%% Collapse to reconstruct
while (i > 1)
    i = i - 1;
    
    %% Collapse
    laplacianF1{i} = laplacian1{i} .* mask{i} + laplacian2{i} .* (1- mask{i});
    laplacianF2{i} = laplacian2{i} .* mask{i} + laplacian1{i} .* (1- mask{i});
    
    imageF1 = imresize(imageF1, [size(laplacianF1{i}, 1) size(laplacianF1{i}, 2)]);
    imageF2 = imresize(imageF2, [size(laplacianF2{i}, 1) size(laplacianF2{i}, 2)]);
    
    imageF1 = imageF1 + laplacianF1{i};
    imageF2 = imageF2 + laplacianF2{i};
    
    %% Progressive display
    cla reset;
    imshow([gaussian1{i} imageF1 gaussian2{i}; laplacian1{i} laplacianF1{i} laplacian2{i}]);
    drawnow;
    %pause(1);
end

%% Display starting and end images
cla reset;
rgbMask = cat(3, mask{i}, mask{i}, mask{i});
imshow([gaussian1{1} gaussian2{1}; imageF1 imageF2]);
imwrite([gaussian1{1} gaussian2{1}; imageF1 imageF2], strcat(directory, '/Blending/','results.jpg'), 'jpg', 'Quality', 95);
drawnow;
