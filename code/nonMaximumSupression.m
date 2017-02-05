%% suppress all overlapping detections including detections at other scales
function [isValid] = nonMaximumSupression(boundingboxes, confidences, imgSize)

%Truncate bounding boxes to image dimensions
xOutOfBounds = boundingboxes(:,3) > imgSize(2);
yOutOfBounds = boundingboxes(:,4) > imgSize(1); 

boundingboxes(xOutOfBounds,3) = imgSize(2);
boundingboxes(yOutOfBounds,4) = imgSize(1);

numberOfDetections = size(confidences,1);

%higher confidence detections get priority.
[confidences, ind] = sort(confidences, 'descend');
boundingboxes = boundingboxes(ind,:);

% indicator for whether each bbox will be accepted or suppressed
isValid = logical(zeros(1,numberOfDetections)); 

for i = 1:numberOfDetections
    cur_bb = boundingboxes(i,:);
    cur_bb_is_valid = true;    
    for j = find(isValid)
        %compute overlap with each previously confirmed bounding box.        
        prev_bb=boundingboxes(j,:);
        bi=[max(cur_bb(1),prev_bb(1));max(cur_bb(2),prev_bb(2));min(cur_bb(3),prev_bb(3));min(cur_bb(4),prev_bb(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(cur_bb(3)-cur_bb(1)+1)*(cur_bb(4)-cur_bb(2)+1)+...
               (prev_bb(3)-prev_bb(1)+1)*(prev_bb(4)-prev_bb(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov > 0.3 
                cur_bb_is_valid = false;
            end            
            center_coord = [(cur_bb(1) + cur_bb(3))/2, (cur_bb(2) + cur_bb(4))/2];
            if( center_coord(1) > prev_bb(1) && center_coord(1) < prev_bb(3) && center_coord(2) > prev_bb(2) && center_coord(2) < prev_bb(4))               
                cur_bb_is_valid = false;
            end
        end
    end    
    isValid(i) = cur_bb_is_valid;
end

reverse_map(ind) = 1:numberOfDetections;
isValid = isValid(reverse_map);

fprintf(' non-maximum suppression: %d detections to %d final bounding boxes\n', numberOfDetections, sum(isValid));


