%function [flow_ffmpeg, flow_frac] = flowmatrix(frame_ffmpeg_mvs, frame_frac_mvs, mvs_x, fmvs_x)
function flow_ffmpeg = flowmatrix(frame_ffmpeg_mvs, mvs_x)

global rows;
global cols;
blocksize = 4;
flow_ffmpeg = nan(rows,cols, 2);
%flow_frac = zeros(rows,cols, 2);
for i = 1 : size(mvs_x, 1)
    for j = 1 : size(mvs_x, 2)
        %for i = 1 : size(fmvs_x, 1)
            %for j = 1 : size(fmvs_x, 2)
                for mb_i = 1 : blocksize
                    for mb_j = 1 : blocksize
                        % conditions, to make sure the matrix doesn't grow more
                        % than x, y
                        if mb_i + (i - 1) * blocksize <= rows ...
                                && mb_j + (j - 1) * blocksize <= cols
                            flow_ffmpeg(mb_i + (i - 1) * blocksize, mb_j + (j - 1) * blocksize, 1)...
                                = frame_ffmpeg_mvs(i, j, 1);
                            flow_ffmpeg(mb_i + (i - 1) * blocksize, mb_j + (j - 1) * blocksize, 2)...
                                = frame_ffmpeg_mvs(i, j, 2);
%                             flow_frac(mb_i + (i - 1) * blocksize, mb_j + (j - 1) * blocksize, 1)...
%                                 = frame_frac_mvs(i, j, 1);
%                             flow_frac(mb_i + (i - 1) * blocksize, mb_j + (j - 1) * blocksize, 2)...
%                                 = frame_frac_mvs(i, j, 2);
                        end
                    end
                end
            %end
        %end
        
    end
end



