function positiveFeatures = getPositiveFeatures(positiveImageDirectory, featureParameters,filetype)

    imageFiles = dir( fullfile( positiveImageDirectory, filetype) );
    numberOfImages = length(imageFiles);
    D = (featureParameters.template_size / featureParameters.hog_cell_size)^2 * 31;
    positiveFeatures = zeros(numberOfImages, D);

    for ii = 1:numberOfImages    
        img = im2single(rgb2gray(imread(strcat(positiveImageDirectory, '/', imageFiles(ii).name))));
        positiveFeatures(ii,:) = reshape(vl_hog(img, featureParameters.hog_cell_size), 1, D);
    end
    
