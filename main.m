clear all;
close all;

% Read video file,set up the video object
v = VideoReader('queen2.mp4');

% First few frames are black so reading after 5 secs.
%v.CurrentTime = 5.0;

global fig_no;
 %global factor; 
 %global blocksize;
global rows;
global cols;
max_motion = 8;
 factor = 0.25;
 blocksize = 4;
mb_size = [blocksize blocksize];
[rows, cols, ~] = size(double(v.read(1)));


% ffprobe queen2.mp4 -show_frames | grep -E 'pict_type|coded_picture_number'
% [mvs_x_all, mvs_y_all] = extract_demo();
% read mvs from file
fprintf('preparing to import mv from ffmpeg.\n');
temp_mvs_file = "tmp/mvs.txt";

[mvs_x, mvs_y, mvs_type, frames_type] = import_mvs(temp_mvs_file, mb_size);
fprintf('done importing mv.\n');



numframes = 2;
%variable for storing the avg mse value of each iteration in array
MSE1 = zeros(numframes, 1);
MSE2 = zeros(numframes, 1);
%MSE2_old = zeros(numframes, 1);
MSE3 = zeros(numframes, 1);
%theta = zeros(numframes, 1);

for i = 120 : 120 + numframes
%for i = 1 : numframes

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
    
    %ffmpeg motion vectors
    ffmpeg_mvs_x = mvs_x(:, :, i);
    ffmpeg_mvs_y = mvs_y(:, :, i);
   
    MSE  = blockmatcher(previous_pic, current_pic);
    MSE1(i) = MSE;
    PSNR1 = 10 * log10((255 ^ 2) / MSE1(i));
    fprintf('PSNR for Block Matching  frame  is  %d.\n', PSNR1);
    
   [MSE, fmvs_x, fmvs_y] = fractionalblockmatching(previous_pic, current_pic);
    MSE2(i) = MSE;
    PSNR2 = 10*log10((255^2) / MSE2(i));
    fprintf('PSNR for Fractional Block Matching is %d. \n', PSNR2);
    
    MSE_ffmpeg = ffmpeg_mse_calc(previous_pic, current_pic, ffmpeg_mvs_x, ffmpeg_mvs_y);
    MSE3(i) = MSE_ffmpeg;
    PSNR3 = 10*log10((255^2) / MSE3(i));
    fprintf('PSNR for FFmpeg MVs is %d. \n', PSNR3);

%     caluclating vector difference
%     v_diff = vector_diff(dx, dy, mvs_x_curr, mvs_y_curr);
%     v_diff(i) = v_diff;
%     fprintf('Vector difference is  %d. \n', v_diff);
%     % calculating angle diff
%     theta = angle_diff (dx, dy, mvs_x_curr, mvs_y_curr);
%     theta(i) = theta;
%     fprintf('Angle difference is  %d. \n', theta);
    
   %plotting inside loop for each frame 
   

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

    % plotting of FFmpeg MV's with fractional vectors
    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), current_pic);
    title('Current picture with superimposed FFmpeg and Fractional vectors');
    axis image;
    colormap(gray(256));
    hold on;
    quiver(horz_pos, vert_pos, fmvs_x, fmvs_y, 0, 'r-');
%     mvs_x_all_ffmpeg = ffmpeg_mvs_x(1 : blocksize : size(ffmpeg_mvs_x, 1) * blocksize,...
%                        1 : blocksize : size(ffmpeg_mvs_x, 2) * blocksize);
%     mvs_y_all_ffmpeg = ffmpeg_mvs_y(1 : blocksize : size(ffmpeg_mvs_x, 1) * blocksize,...
%                        1 : blocksize : size(ffmpeg_mvs_x, 2) * blocksize);
    vert_pos1 = 1 : blocksize : size(ffmpeg_mvs_x, 1) * blocksize;
    vert_pos1 = vert_pos1 + blocksize / 2;
    horz_pos1 = 1 : blocksize : size(ffmpeg_mvs_x, 2) * blocksize ;
    horz_pos1 = horz_pos1 + blocksize / 2;
    quiver(horz_pos1, vert_pos1, ffmpeg_mvs_x, ffmpeg_mvs_y, 0, 'g-');
%     quiver(horz_pos1, vert_pos1, mvs_x_all_ffmpeg, mvs_y_all_ffmpeg, 0, 'g-');
    hold off;

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
    
    
    
   
    
    
    
    
end

MSE1(any(MSE1 == 0, 2), :)= [];
MSE2(any(MSE2 == 0, 2), :)= [];
MSE3(any(MSE3 == 0, 2), :)= [];
%theta(any(theta == 0, 2), :)= [];

% fig_no = fig_no + 1;
% figure(fig_no);
% handle = plot((120 : 120 + numframes), theta, 'rx-');
% 
% %handle = plot( MSE1(i), 'rx-',  MSE2(i), 'g+-');
% %legend('Integer', 'Frac', 'FFmpeg');
% title('Theta diff for  fractional block matching, ffmpeg');
% ylabel('Theta');
% xlabel('Frame Number');
% % This next line sets the xaxis to only have a tick on integers because
% % frames are at integer values
% set(gca, 'XTick', [1 2 3 4]);

fig_no = fig_no + 1;
figure(fig_no);
handle = plot((120 : 120 + numframes), MSE1, 'rx-', ...
              (120 : 120 + numframes), MSE2, 'g+-', ...
              (120 : 120 + numframes), MSE3, 'b*-');

%handle = plot( MSE1(i), 'rx-',  MSE2(i), 'g+-');
legend('Integer', 'Frac', 'FFmpeg');
title('MSE for integer, fractional block matching, ffmpeg');
ylabel('Error MSE');
xlabel('Frame Number');
% This next line sets the xaxis to only have a tick on integers because
% frames are at integer values
set(gca, 'XTick', [1 2 3 4]);