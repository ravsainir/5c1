function MSE = blockmatcher_old(previous_pic, current_pic)
global fig_no;
%Set-up dimension of the image
blocksize = 16;
[rows, cols, channels] = size(previous_pic);

% Now write your own block matcher
max_motion = 8;

% ulhc_x, ulhc_y is the top left hand corner of the block in the 2nd frame
nblocks_v = 0;
nblocks_h = 0;
for ulhc_y = 1 + max_motion : blocksize : rows - blocksize - max_motion,
   nblocks_v = nblocks_v + 1;
end;

for ulhc_x = 1 + max_motion : blocksize : cols - blocksize - max_motion,
   nblocks_h = nblocks_h + 1;
end;



% MAtrix defined for calculating difference
dx = zeros(nblocks_v, nblocks_h);
dy = dx;
%Matrix defined for MAE
dh = zeros(nblocks_v,nblocks_h);
dv = dh;


%%% Estimate the motion between frames 2 -> 1
mcfd = zeros(rows, cols); % For storing the motion compensated error
mcframe = zeros(rows, cols); % For storing 
MAE = zeros(max_motion * 2 + 1 * max_motion * 2 + 1, 3);
error = zeros(max_motion * 2 + 1 * max_motion * 2 + 1, 3);


ny = 1;
for ulhc_y = 1 + max_motion : blocksize : rows - blocksize - max_motion,
  nh = 1;
  for ulhc_x = 1 + max_motion : blocksize : cols - blocksize - max_motion,
    % Now we are at the top left hand corner of a block      
    % Select the block at the current location in the current frame
    x = ulhc_x : ulhc_x + blocksize - 1;
    y = ulhc_y : ulhc_y + blocksize - 1;
    reference_block = double(current_pic(y, x));
    % Now search all the possible motions in the previous frame
    n = 1;
    for x_vec = -max_motion :  max_motion,
      for y_vec = -max_motion : max_motion,
        xx = x + x_vec;
        yy = y + y_vec;
        previous_block = double(previous_pic(yy , xx));
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
      end;
     
    end;
    
    % Now select the best matchng block by checking the min error
    [min_error, index] = min(error(:, 1));
    % and assign the corresponding motion
    dy(ny, nh) = error(index, 2);
    dx(ny, nh) = error(index, 3);
    % Assign the corresponding vector for MAE
    dv(ny, nh) = MAE(index, 2);
    dh(ny, nh) = MAE(index, 3);
    
    % For this best vector, calculate the motion compensated error in 
    % that block
    xx = x + dh(ny, nh);
    yy = y + dv(ny, nh);
    mc_previous_block = double(previous_pic(yy , xx));
    mcfd(y, x) = reference_block - mc_previous_block;
    mcframe(y, x) = mc_previous_block;
     
    nh = nh + 1;
   
  end % End of the horizontal block scan
  ny = ny + 1;
  fprintf('Finished processing row %d.\n', ny);
  
end % End of the vertical block scan
 
% Calculate Mean squared Error for 2 frames
x_window = 1 + max_motion : cols - blocksize - max_motion;
y_window = 1 + max_motion : rows - blocksize - max_motion;
MSE = mean(mean(mean((mcframe(y_window, x_window)...
                           - double(current_pic(y_window, x_window))).^2)));
    
% Plot the vectors on the current figure
vert_pos = 1 + max_motion : blocksize : rows - blocksize - max_motion;
vert_pos = vert_pos + blocksize / 2;
horz_pos = 1 + max_motion : blocksize : cols - blocksize - max_motion;
horz_pos = horz_pos + blocksize / 2;


fig_no = fig_no + 1;
figure(fig_no);
image((1 : cols), (1 : rows), current_pic);
axis image;
colormap(gray(256));
hold on;
quiver(horz_pos, vert_pos, dx, dy, 0, 'r-');
    

images_old(current_pic, previous_pic, mcframe, mcfd, 'Integer Block Matching');
