close all;
clc;

% Read video file,set up the video object
v = VideoReader('queen2.mp4');

% First few frames are black so reading after 5 secs.
%v.CurrentTime = 5.0;

global fig_no;
global rows;
global cols;

blocksize = 4;
mb_size = [blocksize blocksize];

% ffprobe queen2.mp4 -show_frames | grep -E 'pict_type|coded_picture_number'
% read mvs from file
fprintf('preparing to import mv from ffmpeg.\n');
temp_mvs_file = "tmp/mvs.txt";
[mvs_x, mvs_y, mvs_type, frames_type] = import_mvs(temp_mvs_file, mb_size);
fprintf('done importing mv.\n');


% Declaring number of frames
numframes = 2;

% Variable for storing the avg mse value of each iteration in array
MSE1 = zeros(numframes, 1);
MSE2 = zeros(numframes, 1);
MSE3 = zeros(numframes, 1);
PSNR1 = zeros(numframes, 1);
PSNR2 = zeros(numframes, 1);
PSNR3 = zeros(numframes, 1);
v_diff = zeros(numframes, 1);
theta = zeros(numframes, 1);
smoothness_ffmpeg = zeros(numframes, 1);

% Starting from frame 120 because I know the frames with pictures
% start from there
for i = 120 : 120 + numframes
    fig_no = 1;
    previous_pic = read(v, i);
    previous_pic = rgb2gray(previous_pic);
    current_pic = read(v, i + 1);
    current_pic = rgb2gray(current_pic);
    
    figure(fig_no);
    image(previous_pic);
    colormap(gray(256));
    axis image;
    title('Previous Frame');
    
    fig_no = fig_no + 1;
    figure(fig_no);
    image(current_pic);
    colormap(gray(256));
    axis image;
    title('Current Frame');
    
    % FFmpeg motion vectors for the ith frame
    ffmpeg_mvs_x = mvs_x(:, :, i);
    ffmpeg_mvs_y = mvs_y(:, :, i);
    
    % Calculate MSE and PSNR for integer blockmatcher
    [MSE_int, imvs_x, i_mvs_y]  = blockmatcher(previous_pic, current_pic);
    MSE1(i) = MSE_int;
    PSNR1(i) = 10 * log10((255 ^ 2) / MSE1(i));
    fprintf('PSNR for Block Matching  frame  is  %d.\n', PSNR1(i));
    
    % Calculate MSE and PSNR for fractional blockmatcher
    [MSE_frac, fmvs_x, fmvs_y] = fractionalblockmatching(previous_pic, current_pic);
    MSE2(i) = MSE_frac;
    PSNR2(i) = 10*log10((255^2) / MSE2(i));
    fprintf('PSNR for Fractional Block Matching is %d. \n', PSNR2(i));
    
    % Calculate MSE and PSNR for FFmpeg motion vectors
    MSE_ffmpeg = ffmpeg_mse_calc(previous_pic, current_pic, ffmpeg_mvs_x, ffmpeg_mvs_y);
    MSE3(i) = MSE_ffmpeg;
    PSNR3(i) = 10*log10((255^2) / MSE3(i));
    fprintf('PSNR for FFmpeg MVs is %d. \n', PSNR3(i));
    
    
    % Plotting Fractional and FFmpeg Motion vectors inside loop for each frame
    
    % Plotting Frational Motion Vectors on Current Picture
    vert_pos = 1 : blocksize : size(fmvs_x, 1) * blocksize;
    vert_pos = vert_pos + blocksize / 2;
    horz_pos = 1 : blocksize :  size(fmvs_y, 2) * blocksize;
    horz_pos = horz_pos + blocksize / 2;
    suffix = 'Fractional Block Matching';
    
    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), current_pic);
    title(['Current picture for ' suffix]);
    axis image;
    colormap(gray(256));
    hold on;
    quiver(horz_pos, vert_pos, fmvs_x, fmvs_y, 0, 'r-');
    
      % Plot the FFmpeg motion vectors on the current figure
    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), current_pic);
    title('Current picture for FFmpeg MVs');
    axis image;
    colormap(gray(256));
    hold on;
    quiver(horz_pos1, vert_pos1, ffmpeg_mvs_x, ffmpeg_mvs_y, 0, 'g-');
    hold off;
    
    % Plotting of superimposed FFmpeg MV's on  fractional vectors
    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), current_pic);
    title('Current picture with superimposed FFmpeg and Fractional vectors');
    axis image;
    colormap(gray(256));
    hold on;
    quiver(horz_pos, vert_pos, fmvs_x, fmvs_y, 0, 'r-');
    vert_pos1 = 1 : blocksize : size(ffmpeg_mvs_x, 1) * blocksize;
    vert_pos1 = vert_pos1 + blocksize / 2;
    horz_pos1 = 1 : blocksize : size(ffmpeg_mvs_x, 2) * blocksize ;
    horz_pos1 = horz_pos1 + blocksize / 2;
    quiver(horz_pos1, vert_pos1, ffmpeg_mvs_x, ffmpeg_mvs_y, 0, 'g-');
    hold off;
    
  
    
    % Scaling Matrix size of ffmpeg motion vetors with fravtional mv's
    % size of fmvs_x data
    [m,n] = size(fmvs_x);
    % size of ffmpeg_mvs_x data
    [fm,fn] = size(ffmpeg_mvs_x);
    % interpolation grid of fmvs_x' matrix
    [xx,yy] = meshgrid(1:n,1:m);
    % interpolation vectors of 'ffmpeg_mvs_x' matrix
    xt1 = linspace(1,n,fn);
    yt1 = linspace(1,m,fm);
    % interpolation grid of 'ffmpeg_mvs_x' matrix
    [fxx,fyy] = meshgrid(xt1,yt1);
    % interpolate data
    ffmpeg_x = interp2(fxx,fyy,ffmpeg_mvs_x,xx,yy);
    ffmpeg_y = interp2(fxx,fyy,ffmpeg_mvs_y,xx,yy);
    
    
    % % Caluclating vector difference
    v_diff_x(:, :, i) = fmvs_x - ffmpeg_x;
    v_diff_y(:, :, i) = fmvs_y - ffmpeg_y;
    v_diff_x(isnan(v_diff_x)) = 0;
    v_diff_y(isnan(v_diff_y)) = 0;
    v_diff_x(i) = mean(mean(v_diff_x(:, :, i)));
    v_diff_y(i) = mean(mean(v_diff_y(:, :, i)));
    v_diff(i) = sqrt((v_diff_x(i)).^2 + (v_diff_y(i)).^2);
    %fprintf('Vector difference is   %d. \n', v_diff);
    
    % Calculating angle difference
    theta(i)= mean(mean(atan2d(v_diff_y(:, :, i),v_diff_x(:, :, i))));
    theta(isnan(theta))=0;
    fprintf('Angle difference is  %d. \n', theta(i));
    
%creating flow matrix for ffmpeg and fractional mvs
frame_ffmpeg_mvs(:, :, 1) = mvs_x(:, :, i);
frame_ffmpeg_mvs(:, :, 2) = mvs_y(:, :, i);
% frame_frac_mvs(:, :, 1) = fmvs_x(:, :, i);
% frame_frac_mvs(:, :, 2) = fmvs_y(:, :, i);
% Calling Flow matrix function
%[flow_ffmpeg, flow_frac] = flowmatrix(frame_ffmpeg_mvs, frame_frac_mvs, mvs_x, fmvs_x);
flow_ffmpeg = flowmatrix(frame_ffmpeg_mvs, mvs_x);
smoothness_ffmpeg = smoothness_cost_frame(flow_ffmpeg);
smoothness_ffmpeg(i) = smoothness_ffmpeg;

end

% For excluding the 0 values in the matrix before 120th frames
MSE1(any(MSE1 == 0, 2), :)= [];
MSE2(any(MSE2 == 0, 2), :)= [];
MSE3(any(MSE3 == 0, 2), :)= [];
PSNR1(any(PSNR1 == 0, 2), :)= [];
PSNR2(any(PSNR2 == 0, 2), :)= [];
PSNR3(any(PSNR3 == 0, 2), :)= [];
v_diff(any(v_diff == 0, 2), :)= [];
theta(any(theta == 0, 2), :)= [];
smoothness_ffmpeg(any(smoothness_ffmpeg == 0, 2), :)= [];

% Plotting MSE for all 3 motion vectors
fig_no = fig_no + 1;
figure(fig_no);
handle = plot((120 : 120 + numframes), MSE1, 'rx-', ...
    (120 : 120 + numframes), MSE2, 'g+-', ...
    (120 : 120 + numframes), MSE3, 'b*-');
legend('Integer', 'Frac', 'FFmpeg');
title('MSE for integer, fractional block matching, ffmpeg');
ylabel('Error MSE');
xlabel('Frame Number');
% This next line sets the xaxis to only have a tick on integers because
% frames are at integer values
set(gca, 'XTick', [1 2 3 4]);

% Plotting Angle error
fig_no = fig_no + 1;
figure(fig_no);
handle = plot((120 : 120 + numframes), abs(theta), 'rx-');
title('Angle diff for  fractional block matching and  ffmpeg MVs');
ylabel('Theta');
xlabel('Frame Number');
%This next line sets the xaxis to only have a tick on integers because
% frames are at integer values
set(gca, 'XTick', [1 2 3 4]);

% Plotting Smoothness for ffmpeg and fractional mv's 
fig_no = fig_no + 1;
figure(fig_no);
handle = plot((120 : 120 + numframes), smoothness_ffmpeg, 'rx-');
title('Spatial Smoothness for  fractional block matching and  ffmpeg MVs');
ylabel('Smoothness');
xlabel('Frame Number');
%This next line sets the xaxis to only have a tick on integers because
% frames are at integer values
set(gca, 'XTick', [1 2 3 4]);