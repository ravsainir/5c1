%optimized code

function [MSE, fmvs_x, fmvs_y] = fractionalblockmatching(previous_pic, current_pic)

    global fig_no;
    %global blocksize;
    %global factor;
    global frame_size_h;
    global frame_size_w;
    
    factor = 0.5;
    blocksize = 4;
    search_param = 8;
    [frame_size_h, frame_size_w, ~] = size(double(previous_pic));

    frame_size_h_scaled_max = size(1 : factor : frame_size_h, 2);
    frame_size_w_scaled_max = size(1 : factor : frame_size_w, 2);
	Xq = ones(frame_size_h_scaled_max, 1) * (1 : factor : frame_size_w);
    Yq = (1 : factor : frame_size_h)' * ones(1, frame_size_w_scaled_max);
    frame_inter = interp2(double(previous_pic), Xq, Yq);

    nblocks_h = 0;
    nblocks_w = 0;
    
    for ulhc_y = 1 + search_param : blocksize : frame_size_h - blocksize - search_param
        nblocks_w = nblocks_w + 1;
    end 
    for ulhc_x = 1 + search_param : blocksize : frame_size_w - blocksize - search_param
        nblocks_w = nblocks_w + 1;
    end
 
    fmvs_x = zeros(nblocks_h, nblocks_w);
    fmvs_y = fmvs_x;
    % Matrix defined for MAE
    dh = zeros(nblocks_h, nblocks_w);
    dv = dh;

    %%% Estimate the motion between frames 2 -> 1
    mcfd = zeros(frame_size_h, frame_size_w); % For storing the motion compensated error
    mcframe = zeros(frame_size_h, frame_size_w);

    mae = zeros(search_param * 2 + 1 * search_param * 2 + 1, 3);
    error = zeros(search_param * 2 + 1 * search_param * 2 + 1, 3);
    
    mb_y_i = 1;
   
    for mb_y = 1 : blocksize : frame_size_h
        mb_x_i = 1;
        for mb_x = 1 : blocksize : frame_size_w
            x = mb_x : mb_x + blocksize - 1;
            y = mb_y : mb_y + blocksize - 1;
            reference_block = double(current_pic(y, x));

            % Now search all the possible motions in the previous frame
            n = 1;
            error = zeros(1, 1);
            for x_vec = -search_param : factor : search_param
                for y_vec = -search_param  : factor : search_param
                    xx = (x + x_vec) / factor - 1 ;
                    yy = (y + y_vec) / factor - 1;
                    
                    if min(min(xx)) < 1 || max(max(xx)) > frame_size_w_scaled_max || ...
                       min(min(yy)) < 1 || max(max(yy)) > frame_size_h_scaled_max
                        continue;
                    end

                    previous_block = double(frame_inter(yy, xx));
                                       
                    % Now we can calculate the error corresponding to these two blocks
                    error(n, 1) = mean(mean(abs(reference_block - previous_block)));
                    error(n, 2) = y_vec;
                    error(n, 3) = x_vec;

                    % Calculate the motion compensated frame error( Calculate error for each frame)   
                    mae(n,1) = mean(mean(abs(reference_block - previous_block)))/(blocksize^2);
                    mae(n,2) = y_vec;
                    mae(n,3) = x_vec;

                    n = n + 1;
                end
            end
        
            % Now select the best matchng block by checking the min error
            [min_error, index] = min(error(:, 1));
            % and assign the corresponding motion
            fmvs_y(mb_y_i, mb_x_i) = error(index, 2);
            fmvs_x(mb_y_i, mb_x_i) = error(index, 3);
            % Assign the corresponding vector for MAE
            dv(mb_y_i, mb_x_i) = mae(index, 2);
            dh(mb_y_i, mb_x_i) = mae(index, 3);

            % For this best vector, calculate the motion compensated error in that block
            xx = (x + dh(mb_y_i, mb_x_i)) / factor - 1;
            yy = (y + dv(mb_y_i, mb_x_i)) / factor - 1;
            previous_block = double(frame_inter(yy, xx));
            mcfd(y, x) = reference_block - previous_block;
            mcframe(y, x) = previous_block;

            mb_x_i = mb_x_i + 1;
        end
        mb_y_i = mb_y_i + 1;
        fprintf('Finished processing row for FB %d.\n', mb_y_i);
    end
    
    % Calculate Mean squared Error for 2 frames
    MSE = mean(mean(mean((mcframe - double(current_pic)).^2)));

%     suffix = 'Fractional Block Matching';
% 
%     images(current_pic, previous_pic, mcframe, mcfd, suffix);
 % flow(:, :, 1) = mvs_x; flow(:, :, 2) = mvs_y; get_fdkjsf(flow);
    
    
