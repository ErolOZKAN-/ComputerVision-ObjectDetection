%% here, i use vl_feat to speed up the code, otherwise it is too slow.
%%SETUP
close all
clear
run('C:\vlfeat-0.9.20\toolbox\vl_setup')
[~,~,~] = mkdir('visualizations');
%% PARAMETERS
filetype = '*.jpg';
numberOfNegativeExamples = 10000; 
featureParameters = struct('template_size', 36, 'hog_cell_size',6 );
scales = [1,0.85,0.75,0.6,0.5,0.4,0.25,0.15,0.1,0.07];
% PATHS
dataPath = 'data/';
positiveImageDirectory = fullfile(dataPath, 'sign'); 
negativeImageDirectory = fullfile(dataPath, 'nonObject');
testDirectory = fullfile(dataPath,'test');
%% get positive features and negative features
positiveFeatures = getPositiveFeatures( positiveImageDirectory, featureParameters ,filetype);
negativeFeatures = getRandomNegativeFeatures( negativeImageDirectory, featureParameters, numberOfNegativeExamples,filetype);
    
%% train with SVM
lambda = 0.001;
X  = [positiveFeatures; negativeFeatures];
Y  = [ones(size(positiveFeatures,1),1); -1*ones(size(negativeFeatures,1),1)];
[w, b] = vl_svmtrain(X', Y, lambda);
%% examination of learned classifier
fprintf('Initial classifier performance on train data:\n')
confidences = [positiveFeatures; negativeFeatures]*w + b;
labelVector = [ones(size(positiveFeatures,1),1); -1*ones(size(negativeFeatures,1),1)];
[tpRate, fpRate, tnRate, fnRate] =  reportAccuracy( confidences, labelVector );
%%
nonObjectConfs = confidences( labelVector < 0);
objectConfs     = confidences( labelVector > 0);
figure(2); 
plot(sort(objectConfs), 'g'); hold on
plot(sort(nonObjectConfs),'r'); 
plot([0 size(nonObjectConfs,1)], [0 0], 'b');
hold off;
%%
nHogCells = sqrt(length(w) / 31); 
imhog = vl_hog('render', single(reshape(w, [nHogCells nHogCells 31])), 'verbose') ;
figure(3); imagesc(imhog) ; colormap gray; set(3, 'Color', [.988, .988, .988])
%% hog visulation
pause(0.1)
learnedHogTemplate = frame2im(getframe(3));
imwrite(learnedHogTemplate, 'visualizations/hog_template.png')   

%% run detector on test set.
[bboxes, confidences, image_ids] = detect(testDirectory, w, b, featureParameters,scales);

%% visualize detections
visualizeDetections(bboxes, image_ids, testDirectory)
