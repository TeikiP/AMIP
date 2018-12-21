%% Add files to current session
filename = mfilename;
fullpath = mfilename('fullpath');
directory = char(extractBefore(fullpath, length(fullpath)-length(filename)));
addpath(directory, strcat(directory, '/Blending'), strcat(directory, '/Fusion'));

%% Read image
imageName = 'apple.jpg';
image = imread(imageName);
image = im2double(image);
imageOrig = image;
[hOrig, wOrig] = size(image);
[h, w, c] = size(imageOrig);

%% Progressive display initialization
close all;
figure;
ss = get(0, 'Screensize');
set(gcf, 'ToolBar', 'none');
set(gcf, 'Position', [ss(3)/4 ss(4)/4 ss(3)/2 ss(4)/2]);
set(gca, 'Position', [0 0 1 1]);

%% Downsampling
i = 1;
while (h > 10 && w > 10)
    %% Blur
    blur = imgaussfilt(image, 1);
    laplacian{i} = image - blur;

    %% Display figure in a centered half-screensize window
    cla reset;
    imshow([image blur laplacian{i}]);
    drawnow;
    pause(1);
    
    %% Subsampling
    image = imresize(blur, 0.5);
    [h, w, c] = size(image);
    i = i + 1;
end

%% Reconstruction
laplacian = transpose(laplacian);
while (i > 1)
    %% Upsampling
    i = i - 1;
    image = imresize(image, [size(laplacian{i}, 1) size(laplacian{i}, 2)]);
    image = image + laplacian{i};

    %% Display figure in a centered half-screensize window
    cla reset;
    imshow(image);
    drawnow;
    pause(1);
end

%% Display starting and end images
cla reset;
imshow([imageOrig image]);
drawnow;
