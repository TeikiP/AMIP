% Starter script for CSCI 1290 project on Poisson blending. 
% Written by James Hays and Pat Doran.
% imblend.m is the function where you will implement your blending method.
% By default, imblend.m performs a direct composite.

% Disable warning when displaying large images with imshow
warning('off', 'Images:initSize:adjustingMag');

close all
clear variables

data_dir = './../data';
out_dir = './../results';

%there are four inputs for each compositing operation -- 
% 1. 'source' image. Parts of this image will be inserted into 'target'
% 2. 'mask' image. This binary image, the same size as 'source', specifies
%     which pixels will be copied to 'target'
% 3. 'target' image. This is the destination for the 'source' pixels under
%     the 'mask'
% 4. 'offset' vector. This specifies how much to translate the 'source'
%     pixels when copying them to 'target'. These vectors are hard coded
%     below for the default test cases. They are of the form [y, x] where
%     positive values mean shifts down and to the right, respectively.

offset = cell(15,1);
offset{1} = [ 210  10 ];
offset{2} = [  10  28 ];
offset{3} = [ 140  80 ];
offset{4} = [ -40  90 ];
offset{5} = [  60 100 ];
offset{6} = [ -28  88 ];
offset{7} = [   0   0 ];
offset{8} = [ 250 200 ];
offset{9} = [ 45 -48 ];
offset{10} = [ 220 60 ];
offset{11} = [ 0 140 ];
offset{12} = [ 0 0 ];
offset{13} = [ 0 0 ];
offset{14} = [ 0 0 ];
offset{15} = [ 0 0 ];

transparency = ones(length(offset),1);
transparency(5) = .7;
transparency(6) = .5;
transparency(7) = .7;

for i = 1:length(offset)
    source = imread(sprintf('%s/source_%02d.jpg',data_dir,i));
    target = imread(sprintf('%s/target_%02d.jpg',data_dir,i));
    
    if exist(sprintf('%s/mask_%02d.jpg',data_dir,i), 'file') == 2
        mask = imread(sprintf('%s/mask_%02d.jpg',data_dir,i));
        
        if size(mask,3) == 1 % make sure there are 3 color channels
            mask = cat(3, mask, mask, mask);
        end
    else
        mask = getmask(source);
        imwrite(mask, sprintf('%s/mask_%02d.jpg',data_dir,i));
    end
    
    source = im2double(source);
    mask = round(im2double(mask));
    target = im2double(target);
    
    [source, mask, target] = fiximages(source, mask, target, offset{i});
    
    output = imblend(source, mask, target);
    output2 = imblend2(source, mask, target, transparency(i));

    fullProcess = [source mask target output output2];
    
    figure(i)
    imshow(fullProcess)
    
    imwrite(output2,sprintf('%s/result_%02d.jpg',out_dir,i),'jpg','Quality',95);
    imwrite(fullProcess,sprintf('%s/result_full_%02d.jpg',out_dir,i),'jpg','Quality',95);
end

