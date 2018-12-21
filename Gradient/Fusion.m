%% Add files to current session
filename = mfilename;
fullpath = mfilename('fullpath');
directory = char(extractBefore(fullpath, length(fullpath)-length(filename)));
addpath(directory, strcat(directory, '/Blending'), strcat(directory, '/Fusion'));

%% Read image
image1 = im2double(imread('blue_cup.jpg'));
image2 = im2double(imread('green_cup.jpg'));
[h, w, c] = size(image1)

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
    %% Image 1
    blur1 = imgaussfilt(image1, 1);
    gaussian1{i} = image1;
    laplacian1{i} = gaussian1{i} - blur1;
    image1 = imresize(blur1, 0.5);
    
    %% Image 2    
    blur2 = imgaussfilt(image2, 1);
    gaussian2{i} = image2;
    laplacian2{i} = gaussian2{i} - blur2;
    image2 = imresize(blur2, 0.5);
    
    [h, w, c] = size(image1)   
end

%% Restructuring
laplacian1 = transpose(laplacian1);
laplacian2 = transpose(laplacian2);
gaussian1 = transpose(gaussian1);
gaussian2 = transpose(gaussian2);

%% Reconstruction
while (i > 1)
    i = i - 1;
    image1 = imresize(image1, [size(laplacian1{i}, 1) size(laplacian1{i}, 2)]);
    image1 = image1 + laplacian1{i};
end

%% Display starting and end images
cla reset;
imshow([gaussian1{1} image1]);
drawnow;
