%# function: f(x,y)=x^3-2y^2-3x over x=[-2,2], y=[-1,1]
[X Y] = meshgrid(-2:.1:2, -1:.1:1);
Z = X.^3 -2*Y.^2 -3*X;

%# gradient of f
[dX dY] = gradient(Z, .1, .1);

%# plot the vector field and contour levels
figure, hold on
quiver(X, Y, dX, dY)
contour(10)
axis equal, axis([-2 2 -1 1])
hold off
