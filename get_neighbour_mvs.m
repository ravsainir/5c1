% function neighbors = get_neighbour_mvs(x, y)
%   
% neighbors(1) = img(r-1,c-1); % Upper left.  r = row, c = column.
% neighbors(2) = img(r-1,c); % Upper middle.  r = row, c = column.
% neighbors(3) = img(r-1,c+1); % Upper right.  r = row, c = column.
% neighbors(4) = img(r,c-1); % left.  r = row, c = column.
% neighbors(5) = img(r,c+1); % right. r = row, c = column.
% neighbors(6) = img(r+1,c+1); % Lowerleft.  r = row, c = column.
% neighbors(7) = img(r+1,c); % lower middle.  r = row, c = column.
% neighbors(8) = img(r+1,c-1); % Lower left.  r = row, c = column.
% if ~isnan(c_mv_x) && ~isnan(c_mv_y) && c_mv_x ~= 0 && c_mv_y ~= 0 %ignore nan and already added (0, 0) mvs
function neighbours = get_neighbour_mvs(j, i, flow_ffmpeg)

neighbours = nan(3, 3, 2);
start_x = -1; 
start_y = -1;
end_x = 1; 
end_y = 1;
if (j == 1)
    start_x = 0;
end
if (i == 1)    
    start_y = 0;
end   
if (j == size(flow_ffmpeg, 2))
    end_x = 0;    
end
if (i == size(flow_ffmpeg, 1))    
    end_y = 0;
end
 
for nx = start_x : end_x
  for ny = start_y : end_y
    neighbours(2 + ny, 2 + nx, 1) = flow(i + ny, j + nx, 1);
    neighbours(2 + ny, 2 + nx, 2) = flow(i + ny, j + nx, 2);
  end
end

