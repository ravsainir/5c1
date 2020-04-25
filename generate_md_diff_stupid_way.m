function [mse, mcframe] = generate_md_diff_stupid_way(previous_pic, current_pic, mvs_x, mvs_y)

    global blocksize;
    global factor;
    global frame_size_h;
    global frame_size_w;
    
    %Xq = ones(frame_size_h / factor, 1) * (1 : factor : floor((frame_size_w+1)/factor-1)*factor);
    %Yq = (1 : factor : floor((frame_size_h+1)/factor-1)*factor)' * ones(1, frame_size_w / factor);
    
    frame_size_h_scaled_max = size(1 : factor : frame_size_h, 2);
    frame_size_w_scaled_max = size(1 : factor : frame_size_w, 2);
	Xq = ones(frame_size_h_scaled_max, 1) * (1 : factor : frame_size_w);
    Yq = (1 : factor : frame_size_h)' * ones(1, frame_size_w_scaled_max);
    frame_inter = interp2(double(previous_pic), Xq, Yq);
    assert(~any(any(isnan(frame_inter))))
    
    mcfd = zeros(frame_size_h, frame_size_w);
    mcframe = zeros(frame_size_h, frame_size_w);

    mb_y_i = 1;
    for mb_y = 1 : blocksize : frame_size_h
        mb_x_i = 1;
        for mb_x = 1 : blocksize : frame_size_w
            x = mb_x : mb_x + blocksize - 1;
            y = mb_y : mb_y + blocksize - 1;
            reference_block = double(current_pic(y, x));
            
            mv_x = mvs_x(mb_y_i, mb_x_i);
            mv_y = mvs_y(mb_y_i, mb_x_i);
            
            xx = (x + mv_x) / factor - 1;
            yy = (y + mv_y) / factor - 1;
            
            if any(isnan(mv_x)) || any(isnan(mv_y)) || ...
               min(min(xx)) < 1 || max(max(xx)) > frame_size_w_scaled_max || ...
               min(min(yy)) < 1 || max(max(yy)) > frame_size_h_scaled_max
                xx = x; yy = y;
            end
            
            previous_block = double(frame_inter(yy, xx));  
                    
            mcfd(y, x) = reference_block - previous_block;
            mcframe(y, x) = previous_block;
          
            mb_x_i = mb_x_i + 1;
        end
        mb_y_i = mb_y_i + 1;
    end
        
    mse = mean(mean(mean((mcframe - double(current_pic)).^2)));

