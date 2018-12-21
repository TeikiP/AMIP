addpath(genpath('GCMex'));

close all;

%imageRGB = im2double(imread('color_palette.png'));
imageRGB = im2double(imread('komodo.jpg'));
[h, w, c] = size(imageRGB);
nbPix = h*w;

figure('Name','Select the object');
maskObject = roipoly(imageRGB);

figure('Name','Select the background');
maskBackground = roipoly(imageRGB);

close all;

object = imageRGB .* maskObject;
background = imageRGB .* maskBackground;

imageVector = reshape(imageRGB, [], 3);
imageVector = cast(imageVector, 'double'); %TODO

% computation of the paramaters of GCMEX
% random initialization of the classes
class = randi(100, 1, nbPix);
class(class <= 50) = 0;
class(class > 50) = 1;

%grid representation as an adjacency matrix
% computation of the nlinks weights
pairwise = getAdjacencyMatrix(h, w);
[ind1,ind2] = find(pairwise);

gap = std(imageVector(:, 1));

for k = 1:numel(ind1)
    [yp, xp] = ind2sub(size(imageRGB),ind1(k));
    [yq, xq] = ind2sub(size(imageRGB),ind2(k));
    p = image(yp, xp, 1);
    q = image(yq, xq, 1);
    pairwise(ind1(k),ind2(k)) = setPairWiseCost(p, q, gap); %TODO
end


%default value for the labelCost parameter
labelCost = [0 , 1 ; 1 , 0];

% computation of the tlinks weights
for i = 1:c
    [counts,x] = imhist(object(:,:,i));
    meanObject(i) = sum((counts .* x)) / sum(counts);
    stdObject(i) = std(x, counts);

    [counts,x] = imhist(background(:,:,i));
    meanBackground(i) = sum((counts .* x)) / sum(counts);
    stdBackground(i) = std(x, counts);
end

%high = imageVector(imageVector<0.5);
%probHigh = normpdf(imageVector, mean(high), std(high));
probHigh = normpdf(imageVector(:,:), meanObject, stdObject);

%low = imageVector(imageVector>=0.5);
probLow = normpdf(imageVector(:,:), meanBackground, stdBackground);

unary = zeros(2, size(imageVector, 1), c);

for i = 1:c
    for p = 1:size(imageVector, 1)
        unary(1, p, i) = -log(probHigh(p,i));
        unary(2, p, i) = -log(probLow(p,i));
    end
end


[LABELS_RED, ENERGY, ENERGYAFTER] = GCMex(class, single(unary(:,:,1)), pairwise, single(labelCost), 1);
LABELS_RED = reshape(LABELS_RED, h, w);

[LABELS_GREEN, ENERGY, ENERGYAFTER] = GCMex(class, single(unary(:,:,2)), pairwise, single(labelCost), 1);
LABELS_GREEN = reshape(LABELS_GREEN, h, w);

[LABELS_BLUE, ENERGY, ENERGYAFTER] = GCMex(class, single(unary(:,:,3)), pairwise, single(labelCost), 1);
LABELS_BLUE = reshape(LABELS_BLUE, h, w);

LABELS = (LABELS_RED + LABELS_GREEN + LABELS_BLUE) / 3.0;
LABELS = cat(3, LABELS, LABELS, LABELS);

figure();
imshow([imageRGB LABELS]);

function cost = setPairWiseCost (p, q, gap)
    cost = exp(cast(-(((p-q)^2)/(2*gap^2)), 'double'));
end

% https://stackoverflow.com/questions/3277541/construct-adjacency-matrix-in-matlab

function W = getAdjacencyMatrix(m, n)
    I_size = m*n;

    % 1-off diagonal elements
    V = repmat([ones(m-1,1); 0],n, 1);
    V = V(1:end-1); % remove last zero

    % n-off diagonal elements
    U = ones(m*(n-1), 1);

    % get the upper triangular part of the matrix
    W = sparse(1:(I_size-1),    2:I_size, V, I_size, I_size)...
      + sparse(1:(I_size-m),(m+1):I_size, U, I_size, I_size);

    % finally make W symmetric
    W = W + W';
end