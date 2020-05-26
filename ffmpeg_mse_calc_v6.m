% ffmpeg_mvs_x and ffmpeg_mvs_y are the motion vectors for integer block matcher
function MSE_ffmpeg = ffmpeg_mse_calc(previous_pic, current_pic, ffmpeg_mvs_x, ffmpeg_mvs_y)

% global rows;
% global cols;

% Set-up dimension of the image
[rows, cols, ~] = size(previous_pic);
factor = 0.25;
blocksize = 4;
count = 0;

% Let us make up the location of all the pixels in the image
X = ones(rows, 1) * (1 : cols);
Y = (1 : rows)' * ones(1, cols);

% Interpolating whole frame outside the loop
rows_scaled_max = size(1 : factor : rows, 2);
cols_scaled_max = size(1 : factor : cols, 2);
Xq = ones(rows_scaled_max, 1) * (1 : factor : cols);
Yq = (1 : factor : rows)' * ones(1, cols_scaled_max);
frame_inter = interp2(double(previous_pic), Xq, Yq);
assert(~any(any(isnan(frame_inter))))
% For storing the motion compensated error
mcfd = zeros(rows, cols);
% For storing the motion compensated frame
mcframe = zeros(rows, cols);
% for storing the mask associated to the motion compensated frame
mask = zeros(rows, cols);

% Estimate the motion between frames 2 -> 1
ny = 1;
for ulhc_y = 1 : blocksize : rows
  nh = 1;
  for ulhc_x = 1 : blocksize : cols
    x = ulhc_x : ulhc_x + blocksize - 1;
    y = ulhc_y : ulhc_y + blocksize - 1;
    reference_block = double(current_pic(y, x));
    % Motion compensation calculation    
    mv_x = ffmpeg_mvs_x(ny, nh);
    mv_y = ffmpeg_mvs_y(ny, nh);
    xx = (x + mv_x) / factor - 1;
    yy = (y + mv_y) / factor - 1;
    % Make sure  previus_block does not fall outside the picture
    if any(isnan(mv_x)) || any(isnan(mv_y)) || ...
       min(min(xx)) < 1 || max(max(xx)) > cols_scaled_max || ...
       min(min(yy)) < 1 || max(max(yy)) > rows_scaled_max
       xx = x; yy = y;
    end
        
    xxx = ones(length(yy), 1) * xx;
    yyy = yy' * ones(1, length(xx));
    mc_previous_block = interp2(X, Y, double(previous_pic), xxx, yyy);
    mcfd(y, x) = reference_block - mc_previous_block;
    mcframe(y, x) = mc_previous_block;
    % Calculation to ignore nan values in mcframe
    % Creating mask for nan values
    if isnan(mcframe(y, x))
       mask(y, x) = 0;
    else
       mask(y, x) = 1;
       count = count + 1;
    end
    
    nh = nh + 1;
  end
  ny = ny + 1;
end

% Making nan values zero in mcframe
mcframe(isnan(mcframe)) = 0;
MSE_ffmpeg = mean(mean((mcframe - double(current_pic)).^2))/count;
