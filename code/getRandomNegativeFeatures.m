function negativeFeatures = getRandomNegativeFeatures(nonObjectDirectory, featureParemeters, numberOfSamples,filetype)

    imageFiles = dir( fullfile( nonObjectDirectory, filetype ));
    numberOfImages = length(imageFiles);
    numSamplePerImg = ceil(numberOfSamples/numberOfImages);
    D = (featureParemeters.template_size / featureParemeters.hog_cell_size)^2 * 31;
    feat_size = featureParemeters.template_size;
    negativeFeatures = zeros(numberOfImages, D);

    for ii = 1:numberOfImages
        img = im2single(rgb2gray(imread(strcat(nonObjectDirectory, '/', imageFiles(ii).name))));
        [height, width] = size(img);
        for jj = 1:numSamplePerImg
            top_left_x = ceil(rand()*(width-feat_size));
            top_left_y = ceil(rand()*(height-feat_size));
            if top_left_x<1 || top_left_y<1
               continue;
            end
            index = (ii-1)*numSamplePerImg + jj;
            cropped = img(top_left_y:top_left_y+feat_size-1, top_left_x:top_left_x+feat_size-1);
            negativeFeatures(index,:) = reshape(vl_hog(cropped, featureParemeters.hog_cell_size), 1, D);
        end
    end
