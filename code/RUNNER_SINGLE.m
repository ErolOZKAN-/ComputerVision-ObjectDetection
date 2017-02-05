clear all;

objectToDetect = 'singleData/object.png';
%objectToDetect = 'singleData/object2.png';
imageToRead = 'singleData/002603.jpg';
fileToWrite = 'detections.png';
treshold = 10;

hogParameters.numBins = 9;%number of bins
hogParameters.numHorizCells = 8;%number of cells in x direction
hogParameters.numVertCells = 16;%number of cells in y direction
hogParameters.cellSize = 8; %pixel number in image
hogParameters.winSize = [(hogParameters.numVertCells * hogParameters.cellSize + 2),(hogParameters.numHorizCells * hogParameters.cellSize + 2)];% Expected window size.

objectImage = imread(objectToDetect);
objectImage = rgb2gray(objectImage);

[anglesForObject,magnitutesForObject] = compute_gradients(hogParameters, objectImage);
descriptorForObject = hog(hogParameters,anglesForObject,magnitutesForObject);

image = imread(imageToRead);
grayImage = rgb2gray(image);
[height width] = size (grayImage);

confidenceMatrix = zeros();%all confidence matrix
cur_bboxes = [];%detected instances
cur_confidences = [];%detected instances confidence as list

for i=1:8:(height-130)
    for j=1:8:(width-66)  
        cropped =grayImage(i:i+130-1, j: j+66-1);
        [angles,magnitutes] = compute_gradients(hogParameters, cropped);
        descriptorForPatch = hog(hogParameters,angles,magnitutes);
        DIFF = descriptorForObject-descriptorForPatch;
        DIFF = sum(DIFF.*DIFF);        
        confidenceMatrix(ceil(i/8),ceil(j/8)) = DIFF;       
        if DIFF < treshold
            cur_confidences = [cur_confidences; DIFF];
            cur_bboxes = [cur_bboxes; j i j+66 i+130];
        end
    end
end

visualizeConfidence(confidenceMatrix);

[is_maximum] = nonMaximumSupression(cur_bboxes, cur_confidences, size(image));
cur_confidences = cur_confidences(is_maximum,:);
cur_bboxes      = cur_bboxes(     is_maximum,:);

visualizeBoxes(image,cur_bboxes,fileToWrite);

