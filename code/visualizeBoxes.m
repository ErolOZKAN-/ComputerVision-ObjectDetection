function visualizeBoxes(img,cur_bboxes,filePath)   
   figure (15),
   imshow(img);
   hold on;
   
   for i = 1:size(cur_bboxes,1)
        bb = cur_bboxes(i,:);
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g:','linewidth',5);
   end
   
   hold off;
   axis image;
   axis off;
   title(sprintf('imAge: Single Instance Matching'),'interpreter','none');

   detection_image = frame2im(getframe(15));
   imwrite(detection_image,filePath);  
   