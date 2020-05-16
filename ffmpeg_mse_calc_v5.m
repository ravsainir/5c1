% ffmpeg_mvs_x and ffmpeg_mvs_y are the motion vectors for integer block matcher
function MSE_ffmpeg = ffmpeg_mse_calc(previous_pic, current_pic, ffmpeg_mvs_x, ffmpeg_mvs_y)

     global rows;
     global cols;
     
% Set-up dimension of the image
    [rows, cols, ~] = size(previous_pic);
     factor = 0.25;
     blocksize = 4;

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

% Estimate the motion between frames 2 -> 1
    ny = 1;
    for ulhc_y = 1 : blocksize : rows
        nh = 1;
        for ulhc_x = 1 : blocksize : cols
            x = ulhc_x : ulhc_x + blocksize - 1;
            y = ulhc_y : ulhc_y + blocksize - 1;
            reference_block = double(current_pic(y, x));
            
            mv_x = ffmpeg_mvs_x(ny, nh);
            mv_y = ffmpeg_mvs_y(ny, nh);
            
            xx = (x + mv_x) / factor - 1;
            yy = (y + mv_y) / factor - 1;
            
            if any(isnan(mv_x)) || any(isnan(mv_y)) || ...
               min(min(xx)) < 1 || max(max(xx)) > cols_scaled_max || ...
               min(min(yy)) < 1 || max(max(yy)) > rows_scaled_max
               xx = x; yy = y;
            end
            
            previous_block = double(frame_inter(yy, xx));  
                    
            mcfd(y, x) = reference_block - previous_block;
            mcframe(y, x) = previous_block;
          
            nh = nh + 1;
        end
        ny = ny + 1;
    end
        
    MSE_ffmpeg = mean(mean(mean((mcframe - double(current_pic)).^2)));
