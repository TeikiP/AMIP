%% Add files to current session
filename = mfilename;
fullpath = mfilename('fullpath');
directory = char(extractBefore(fullpath, length(fullpath)-length(filename)));
addpath(directory, strcat(directory, '/images'), strcat(directory, '/results'));

%% Read image
imageName = 'texture2.bmp';
image = imread(imageName);
image = im2double(image);

%% Synthesis
seedSize = 5;
synth = TextureGrowing(image, seedSize, 1);
%synth = TextureInpainting(image, seedSize);
imwrite(synth, strcat(strcat(directory, '/results/output_'), imageName));


%% Display figure in a centered half-screensize window
ss = get(0, 'Screensize');

close all;
figure;
set(gcf, 'ToolBar', 'none');
set(gcf, 'Position', [ss(3)/4 ss(4)/4 ss(3)/2 ss(4)/2]);
set(gca, 'Position', [0 0 1 1]);
imshow(synth);
