function visualizeDetections(boundingBoxes, imageIds, testDirectory)

testFiles = dir(fullfile(testDirectory, '*.jpeg'));
numberOfTestImages = length(testFiles);

for i=1:numberOfTestImages
    
   image = imread( fullfile( testDirectory, testFiles(i).name));      
   detections = strcmp(testFiles(i).name, imageIds);
   bboxes = boundingBoxes(detections,:);
   
   figure(15)
   imshow(image);
   hold on;
   
   num_detections = sum(detections);
   
   for j = 1:num_detections
       bb = bboxes(j,:);
       plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g:','linewidth',5);
   end
 
   hold off;
   axis image;
   axis off;
   title(sprintf('imAge: %s', testFiles(i).name),'interpreter','none');
    
   set(15, 'Color', [.988, .988, .988])
   pause(0.1) 
   detection_image = frame2im(getframe(15));

   imwrite(detection_image, sprintf('visualizations/detections_%s.png', testFiles(i).name))
   
   fprintf('press any key to continue with next image\n');
   pause;
   
end



