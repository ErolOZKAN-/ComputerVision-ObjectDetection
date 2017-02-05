%% Compute Gradient Source Code
function [angles,magnitude] = compute_gradients(hog, img)
% be sure that the input image size matches the HOG parameters.
assert(isequal(size(img), hog.winSize))

% Create the operators for computing image derivative at every pixel.
hx = [-1,0,1];
hy = hx';

% Compute the derivative in the x and y direction for every pixel.
dx = filter2(hx, double(img));
dy = filter2(hy, double(img));

% Remove the 1 pixel border.
dx = dx(2 : (size(dx, 1) - 1), 2 : (size(dx, 2) - 1));
dy = dy(2 : (size(dy, 1) - 1), 2 : (size(dy, 2) - 1)); 

% Convert the gradient vectors to polar coordinates (angle and magnitude).
angles = atan2(dy, dx);
magnitude = ((dy.^2) + (dx.^2)).^.5;
end
