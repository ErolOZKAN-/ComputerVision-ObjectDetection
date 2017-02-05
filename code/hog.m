% =================================
%     Compute Cell Histograms 
% =================================
% Computes the histogram for every cell in the image. We'll combine the cells
% into blocks and normalize them later.
function H = hog(hogParameters,angles,magnit)

H = [];

% Create a three dimensional matrix to hold the histogram for each cell.
histograms = zeros(hogParameters.numVertCells, hogParameters.numHorizCells, hogParameters.numBins);

% For each cell in the y-direction...
for row = 0:(hogParameters.numVertCells - 1)
    
    % Compute the row number in the 'img' matrix corresponding to the top
    % of the cells in this row. Add 1 since the matrices are indexed from 1.
    rowOffset = (row * hogParameters.cellSize) + 1;
    
    % For each cell in the x-direction...
    for col = 0:(hogParameters.numHorizCells - 1)
    
        % Select the pixels for this cell.
        
        % Compute column number in the 'img' matrix corresponding to the left
        % of the current cell. Add 1 since the matrices are indexed from 1.
        colOffset = (col * hogParameters.cellSize) + 1;
        
        % Compute the indices of the pixels within this cell.
        rowIndeces = rowOffset : (rowOffset + hogParameters.cellSize - 1);
        colIndeces = colOffset : (colOffset + hogParameters.cellSize - 1);
        
        % Select the angles and magnitudes for the pixels in this cell.
        cellAngles = angles(rowIndeces, colIndeces); 
        cellMagnitudes = magnit(rowIndeces, colIndeces);
    
        % Compute the histogram for this cell.
        % Convert the cells to column vectors before passing them in.
        histograms(row + 1, col + 1, :) = getHistogram(cellMagnitudes(:), cellAngles(:), hogParameters.numBins);
    end
    
end

% ===================================
%       Block Normalization
% ===================================    

% Take 2 x 2 blocks of cells and normalize the histograms within the block.
% Normalization provides some invariance to changes in contrast, which can
% be thought of as multiplying every pixel in the block by some coefficient.

% For each cell in the y-direction...
for row = 1:2:(hogParameters.numVertCells - 1)    
    % For each cell in the x-direction...
    for col = 1:2:(hogParameters.numHorizCells - 1)
    
        % Get the histograms for the cells in this block.
        blockHists = histograms(row : row + 1, col : col + 1, :);
        
        % Put all the histogram values into a single vector (nevermind the 
        % order), and compute the magnitude.
        % Add a small amount to the magnitude to ensure that it's never 0.
        magnitude = norm(blockHists(:)) + 0.01;
    
        % Divide all of the histogram values by the magnitude to normalize 
        % them.
        normalized = blockHists / magnitude;
        
        % Append the normalized histograms to our descriptor vector.
        H = [H; normalized(:)];
    end
end