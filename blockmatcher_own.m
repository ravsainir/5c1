close all;
clear all;

% Read the video file
v = VideoReader('queen2.mp4');

% Read first two frames and convert them to grayscale
% Since first few frames are blank starting from 5 sec
v.CurrentTime = 5.0;
First_frame = readFrame(v);
Previous_pic = rgb2gray(First_frame);
figure(1);
imshow(Previous_pic);
title('Previous Pic','fontsize',20);
Second_frame = readFrame(v);
Current_pic = rgb2gray(Second_frame);
figure(2);
imshow(Current_pic);
title('Current Pic','fontsize',20);

% Setting up dimension of the image
blocksize = 16;
[rows, cols, channels] = size(Previous_pic);
max_motion = 8;

%ulhc_y and ulhc_x co-ordinate of the upper left hand corner of the block
%nblocks_v and nblocks_h are vertical and horizantal block
nblocks_h = 0;
nblocks_v = 0;

for ulhc_y = 1 : blocksize : rows - blocksize
    nblocks_v = nblocks_v + 1;
end;
for ulhc_x = 1: blocksize : cols - blocksize
    nblocks_h = nblocks_h + 1;
end;

%Matrix for calculating difference
dx = zeros(nblocks_v, nblocks_h);
dx = dy;
threshold = 10;

%Estimate motion between frame 2 --> 1



