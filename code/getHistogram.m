%% Computes a histogram 
%   This function takes magnitudes and angles then places them into a
%   histogram with 'numberOfBins' based on their unsigned orientation. 
%   A gradient's contribution to the histogram is equal to its magnitude;
%   the magnitude is divided between the two nearest bin centers.
%   Normalizitation step is important.
function Histogram = getHistogram(magnitudes, angles, numberOfBins)

binSize = pi / numberOfBins;
minAngle = 0;
angles(angles < 0) = angles(angles < 0) + pi;

leftBinIndex = round((angles - minAngle) / binSize);
rightBinIndex = leftBinIndex + 1;

% For each pixel, compute the center of the bin to the left.
leftBinCenter = ((leftBinIndex - 0.5) * binSize) - minAngle;

% For each pixel, compute the fraction of the magnitude
% to contribute to each bin.
rightPortions = angles - leftBinCenter;
leftPortions = binSize - rightPortions;
rightPortions = rightPortions / binSize;
leftPortions = leftPortions / binSize;

% Replace index 0 with 9 and index 10 with 1.
leftBinIndex(leftBinIndex == 0) = numberOfBins;
rightBinIndex(rightBinIndex == (numberOfBins + 1)) = 1;

% Create an empty row vector for the histogram.
Histogram = zeros(1, numberOfBins);

% For each bin index...
for i = 1:numberOfBins
    % Find the pixels with left bin == i
    pixels = (leftBinIndex == i);        
    % For each of the selected pixels, add the gradient magnitude to bin 'i',
    % weighted by the 'leftPortion' for that pixel.
    Histogram(1, i) = Histogram(1, i) + sum(leftPortions(pixels)' * magnitudes(pixels));
    
    % Find the pixels with right bin == i
    pixels = (rightBinIndex == i);
        
    % For each of the selected pixels, add the gradient magnitude to bin 'i',
    % weighted by the 'rightPortion' for that pixel.
    Histogram(1, i) = Histogram(1, i) + sum(rightPortions(pixels)' * magnitudes(pixels));
end    

end