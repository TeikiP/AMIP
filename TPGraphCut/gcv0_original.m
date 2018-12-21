addpath(genpath('GCMex'));

image = [200 230 200; 230 200 10; 50 10 50];
imageVector = reshape(image, [], 1);
h = 3;
w = 3;
nbPix = h*w;

% computation of the paramaters of GCMEX
% random initialization of the classes
class = randi(100, 1, nbPix);
class(class <= 50) = 0;
class(class > 50) = 1;

%grid representation as an adjacency matrix
% computation of the nlinks weights
pairwise = getAdjacencyMatrix(h, w);
[ind1,ind2] = find(pairwise);

gap = std(imageVector);

for k = 1:numel(ind1)
    [yp, xp] = ind2sub(size(image),ind1(k));
    [yq, xq] = ind2sub(size(image),ind2(k));
    p = image(yp, xp);
    q = image(yq, xq);
    pairwise(ind1(k),ind2(k)) = setPairWiseCost(p, q, gap); 
end


%default value for the labelCost parameter
labelCost = [0 , 1 ; 1 , 0];

% computation of the tlinks weights
high = imageVector(imageVector<128);
probHigh = normpdf(imageVector, mean(high), std(high));

low = imageVector(imageVector>=128);
probLow = normpdf(imageVector, mean(low), std(low));


unary = zeros(2,size(imageVector, 1));

for p = 1:size(imageVector, 1)
    unary(1, p) = -log(probHigh(p));
    unary(2, p) = -log(probLow(p));
end


[LABELS, ENERGY, ENERGYAFTER] = GCMex(class, single(unary), pairwise, single(labelCost), 1);
LABELS = reshape(LABELS, h, w);

figure();
imshow(LABELS)


function cost = setPairWiseCost (p, q, gap)
    cost = exp(-(((p-q)^2)/(2*gap^2)));
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