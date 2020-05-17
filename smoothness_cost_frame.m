% uses smoothness_cost_mv to calculate mean
% returns mean of smoothness costs of mvs. ignores nan mvs
% warns about isolated mv. if mv has all nan surroundings
% flow(:, :, 1) = mvs_x; flow(:, :, 2) = mvs_y; get_fdkjsf(flow);
function smoothness_ffmpeg = smoothness_cost_frame(flow_ffmpeg)
smoothness = nan(1, 1);
smoothness_i = 1;
for i = 1 : size(flow_ffmpeg, 1)
  for j = 1 : size(flow_ffmpeg, 2)
    mv_x = flow_ffmpeg(i, j, 1);
    mv_y = flow_ffmpeg(i, j, 2);
    neighbours = get_neighbour_mvs(j, i, flow_ffmpeg);
    % don't include cost of nan mv in costs
    if isnan(mv_x) || isnan(mv_y)
       continue;
    end
    
     
    e_dists = nan(1, 1);
    e_dists_i = 1;
    for i = 1 : 3
        for j = 1 : 3
            if (i == 2 && j == 2) || isnan(neighbours(i, j, 1)) ||...
                    isnan(neighbours(i, j, 2))
                continue; % ignore centre val
            end
            mv_d = [mv_x, mv_y] - [neighbours(i, j, 1), neighbours(i, j, 2)];
            % TODO multiply with diagonal factor
            e_dists(e_dists_i) = sqrt(mv_d * mv_d');
            e_dists_i = e_dists_i + 1;
        end
    end
    
    smoothness = sum(e_dists);
    if ~isnan(smoothness)
        smoothness(smoothness_i) = smoothness;
        smoothness_i = smoothness_i + 1;
    else
        fprintf('warning: (isolated mv?) the smoothness cost is nan at (i, j): %d, %d\n', i, j);
        
    end
  end
end
smoothness_ffmpeg = mean(smoothness);


    



