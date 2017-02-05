function [boundryBoxes, confidences, imageIds] = detect(testDirectory, w, b, featureParameters,scales)

testScenes = dir( fullfile( testDirectory, '*.jpeg' ));
boundryBoxes = zeros(0,4);
confidences = zeros(0,1);
imageIds = cell(0,1);
cellSize = featureParameters.hog_cell_size;

for i = 1:length(testScenes)
      
    fprintf('Detecting Objects in %s\n', testScenes(i).name)
    img = imread( fullfile( testDirectory, testScenes(i).name ));
    img = single(img)/255;
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    cur_bboxes = zeros(0,4);
    cur_confidences = zeros(0,1);
    cur_image_ids = cell(0,1);
    for scale = scales
        img_scaled = imresize(img, scale);
        [height, width] = size(img_scaled);    

        test_features = vl_hog(img_scaled, featureParameters.hog_cell_size);
        img_num_cell_x = floor(width/featureParameters.hog_cell_size);
        img_num_cell_y = floor(height/featureParameters.hog_cell_size);

        temp_num_cell = featureParameters.template_size / cellSize;

        num_window_x = img_num_cell_x - temp_num_cell + 1;
        num_window_y = img_num_cell_y - temp_num_cell + 1;

        D = temp_num_cell^2*31;
        window_feats = zeros(num_window_x * num_window_y, D);
        for x = 1:num_window_x
            for y = 1:num_window_y
                window_feats((x-1)*num_window_y+ y,:) = ...
                    reshape(test_features(y:(y+temp_num_cell-1),x:(x+temp_num_cell-1),:), 1,D);
            end
        end
        scores = window_feats * w +b;
        indices = find(scores>0.50);
        curscale_confidences = scores(indices);

        detected_x = floor(indices./num_window_y);
        detected_y = mod(indices, num_window_y)-1;
        curscale_bboxes = [cellSize*detected_x+1, cellSize*detected_y+1, ...
            cellSize*(detected_x+temp_num_cell), cellSize*(detected_y+temp_num_cell)]./scale;
        curscale_image_ids = repmat({testScenes(i).name}, size(indices,1), 1);
       
        cur_bboxes      = [cur_bboxes;      curscale_bboxes];
        cur_confidences = [cur_confidences; curscale_confidences];
        cur_image_ids   = [cur_image_ids;   curscale_image_ids];
    end

    [is_maximum] = nonMaximumSupression(cur_bboxes, cur_confidences, size(img));

    cur_confidences = cur_confidences(is_maximum,:);
    cur_bboxes      = cur_bboxes(     is_maximum,:);
    cur_image_ids   = cur_image_ids(  is_maximum,:);
    boundryBoxes      = [boundryBoxes;      cur_bboxes];
    confidences = [confidences; cur_confidences];
    imageIds   = [imageIds;   cur_image_ids];
end




