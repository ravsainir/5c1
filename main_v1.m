clear all;
close all;

% Read video file,set up the video object
v = VideoReader('queen2.mp4');

% First few frames are black so reading after 5 secs.
v.CurrentTime = 5.0;

global fig_no;


numframes = 4;
% Variable for storing the avg mse value of each iteration in array
MSE1 = zeros(numframes, 1);
MSE2 = zeros(numframes, 1);

for i = 1 : numframes
    fig_no = 1;

    First_frame = readFrame(v);
    previous_pic = rgb2gray(First_frame);
    Second_frame = readFrame(v);
    current_pic = rgb2gray(Second_frame);

    
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
  
    MSE = blockmatcher_old(previous_pic, current_pic);
    MSE1(i) = MSE;
    MSE = fractionalblockmatching_old(previous_pic, current_pic);
    MSE2(i) = MSE;
   
    
end

fig_no = fig_no + 1;
figure(fig_no);
handle = plot((1 : numframes), MSE1, 'rx-', (1 : numframes), MSE2, 'g+-');
legend('Integer', 'Frac');
title('MSE for integer and fractional block matching');
ylabel('Error MSE');
xlabel('Frame Number');
% This next line sets the xaxis to only have a tick on integers because
% frames are at integer values
set(gca, 'XTick', [1 2 3 4]);








