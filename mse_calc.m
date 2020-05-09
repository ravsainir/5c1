function mse = mse_calc(previous_pic, current_pic, mvs_x, mvs_y)

    %Set-up dimension of the image
    [rows, cols, ~] = size(previous_pic);
    % Now write your own block matcher
    blocksize = 4;
    
    
    mse = zeros(rows / blocksize, cols / blocksize);
    mh = 1
    for x = 1 : blocksize : rows
        my = 1;
        for y = 1 : blocksize : cols
             previous_block_mvs = double(previous_pic(mvs_x , mvs_y));
             xx = x + mvs_x;
             yy = y + mvs_y;
             mc_previous_block = double(previous_pic(yy , xx));
             mcframe(y, x) = mc_previous_block;
             mh = mh + 1;
             fprintf('Finished processing FFmpeg row %d\n', mh);
             end % End of the horizontal block scan
             my = my + 1;
             fprintf('Finished processing FFmpeg row %d.\n', my);
            
        end
    end
    
   mse = mean(mean(mean((mcframe_mvs(y, x)- double(current_pic(y, x))).^2)));
  

%  % extacting MV's
%     ffmpeg_mvs(:, 1) = dx_mvs(:, :);
%     ffmpeg_mvs(:, 2) = dy_mvs(:, :);