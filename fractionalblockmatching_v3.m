function [MSE, fmvs_x, fmvs_y] = fractionalblockmatching_v3(previous_pic, current_pic)
%function MSE = fractionalblockmatching(previous_pic, current_pic)

global fig_no;
%global factor
% Set-up dimension of the image
blocksize = 4;
factor = 0.5;
max_motion = 8;

[rows, cols, ~] = size(double(previous_pic));


% Let us make up the location of all the pixels in the image

X = ones(rows, 1) * (1 : cols);

Y = (1 : rows)' * ones(1, cols);

% Interpolating whole frame outside the loop
rows_scaled_max = size(1 : factor : rows, 2);
cols_scaled_max = size(1 : factor : cols, 2);

Xq = ones(rows / factor, 1) * (1 : factor : cols + factor);
Yq = (1 : factor : rows + factor)' * ones(1, cols / factor);
% Xq = ones(rows_scaled_max, 1) * (1 : factor : rows);
% Yq = (1 : factor : cols)' * ones(1, cols_scaled_max);
frame_inter = interp2(double(previous_pic), Xq, Yq);

% ulhc_x, ulhc_y is the top left hand corner of the block in the 2nd frame
nblocks_v = 0;
nblocks_h = 0;

for ulhc_y = 1 + max_motion : blocksize : rows - blocksize - max_motion
    nblocks_v = nblocks_v + 1;
end
for ulhc_x = 1 + max_motion : blocksize : cols - blocksize - max_motion
    nblocks_h = nblocks_h + 1;
end

% Matrix defined for calculating difference
fmvs_x = zeros(nblocks_v, nblocks_h);
fmvs_y = fmvs_x;
% Matrix defined for MAE
dh = zeros(nblocks_v,nblocks_h);
dv = dh;

% Estimate the motion between frames 2 -> 1

% For storing the motion compensated error
mcfd = zeros(rows, cols);
% For storing the motion compensated frame
mcframe = zeros(rows, cols);
MAE = zeros(max_motion * 2 + 1 * max_motion * 2 + 1, 3);
%error = zeros(max_motion * 2 + 1 * max_motion * 2 + 1, 3);

ny = 1;
for ulhc_y = 1 : blocksize : rows
    nh = 1;
    for ulhc_x = 1 : blocksize : cols
        % Now we are at the top left hand corner of a block
        % Select the block at the current location in the current frame
        x = ulhc_x : ulhc_x + blocksize - 1;
        y = ulhc_y : ulhc_y + blocksize - 1;
        reference_block = double(current_pic(y, x));
        
        % Now search all the possible motions in the previous frame
        n = 1;
        error = zeros(1, 1);
        for x_vec = -max_motion : factor : max_motion
            for y_vec = -max_motion  : factor : max_motion
                xx = (x + x_vec) / factor - 1;
                yy = (y + y_vec) / factor - 1;
                %if %any(isnan(fmvs_x)) || any(isnan(fmvs_y)) || ...
                  if min(min(xx)) < 1 || max(max(xx)) > cols_scaled_max || ...
                     min(min(yy)) < 1 || max(max(yy)) > rows_scaled_max
                     continue;
                  end
                previous_block = double(frame_inter(yy, xx));
                %previous_block = double(previous_pic(yy , xx));
                % Now we can calculate the error corresponding to these two blocks
                error(n, 1) = mean(mean(abs(reference_block - previous_block)));
                error(n, 2) = y_vec;
                error(n, 3) = x_vec;
                % Calculate the motion compensated frame error( Calculate...
                %            error for each frame)
                MAE(n,1) = mean(mean(abs(reference_block - previous_block)))/...
                    (blocksize^2);
                MAE(n,2) = y_vec;
                MAE(n,3) = x_vec;
                n = n + 1;
            end
        end
        
        % Now select the best matchng block by checking the min error
        [min_error, index] = min(error(:, 1));
        % and assign the corresponding motion
        fmvs_y(ny, nh) = error(index, 2);
        fmvs_x(ny, nh) = error(index, 3);
        % Assign the corresponding vector for MAE
        dv(ny, nh) = MAE(index, 2);
        dh(ny, nh) = MAE(index, 3);
        
        % For this best vector, calculate the motion compensated error in
        % that block
        xx = x + dh(ny, nh) / factor - 1;
        yy = y + dv(ny, nh) / factor - 1;
        xxx = ones(length(yy), 1) * xx;
        yyy = yy' * ones(1, length(xx));
        mc_previous_block = interp2(X, Y, double(previous_pic), xxx, yyy);
        %mc_previous_block = double(frame_inter(yy, xx));
        mcfd(y, x) = reference_block - mc_previous_block;
        mcframe(y, x) = mc_previous_block;
        nh = nh + 1;
        fprintf('Finished processing block for FB %d\n', nh);
    end % End of the horizontal block scan
    ny = ny + 1;
    fprintf('Finished processing row for FB %d.\n', ny);
end % End of the vertical block scan

% Calculate Mean squared Error for 2 frames
MSE = mean(mean(mean((mcframe - double(current_pic)).^2)));

%     %figure(); 
%     image( mcfd );
%     colormap(gray(256));
% 
% % Plot the vectors on the current figure
% 
% %vert_pos = 1 : blocksize : size(fmvs_x, 1) * blocksize;
% vert_pos = vert_pos + blocksize / 2;
% 
% %horz_pos = 1 : blocksize : size(fmvs_x, 2) * blocksize;
% horz_pos = horz_pos + blocksize / 2;
% 
 suffix = 'Fractional Block Matching';
% 
% % plotting of FFmpeg MV's with Fractional vectors
% fig_no = fig_no + 1;
% figure(fig_no);
% image((1 : cols), (1 : rows), current_pic);
% title('Current picture with  Fractional vectors');
% axis image;
% colormap(gray(256));
% quiver(horz_pos, vert_pos, fmvs_x, fmvs_y, 0, 'r-');
% 
% fig_no = fig_no + 1;
% figure(fig_no);
% image((1 : cols), (1 : rows), current_pic);
% title('Current picture with superimposed FFmpeg and Fractional vectors');
% axis image;
% colormap(gray(256));
% hold on;
% quiver(horz_pos, vert_pos, fmvs_x, fmvs_y, 0, 'r-');
%  
% % mvs_x_all = ffmpeg_mvs_x(1 : blocksize/4 : size(ffmpeg_mvs_x, 1),...
% %             1 : blocksize/4 : size(ffmpeg_mvs_x, 2));
% % mvs_y_all = ffmpeg_mvs_y(1 : blocksize/4 : size(ffmpeg_mvs_y, 1),...
% %             1 : blocksize/4 : size(ffmpeg_mvs_y, 2));
% % vert_pos1 = 1 : blocksize : size(ffmpeg_mvs_x, 1) * blocksize;
% % vert_pos1 = vert_pos1 + blocksize / 2;
% % horz_pos1 = 1 : blocksize : size(ffmpeg_mvs_x, 2) * blocksize;
% % horz_pos1 = horz_pos1 + blocksize / 2;
% quiver(horz_pos, vert_pos, mvs_x_all, mvs_y_all, 0, 'g-');
% hold off;
% 
% %Plot the FFmpeg motion vectors on the current figure
% fig_no = fig_no + 1;
% figure(fig_no);
% image((1 : cols), (1 : rows), current_pic);
% title('Current picture for FFmpeg MVs');
% axis image;
% colormap(gray(256));
% hold on;
% quiver(horz_pos, vert_pos, mvs_x_all, mvs_y_all, 0, 'g-');
% 
% hold off;

images(current_pic, previous_pic, mcframe, mcfd, suffix);

