function [mvs_x, mvs_y] = extract_demo()

% global rows;
%  global cols;

mb_size = [4, 4]; % h x w


%frames_dir = "sintel/training/final/alley_1";
frames_dir = "queen2";


orig_input_file_fmt = sprintf('%s/frame_%%04d.png', frames_dir);

% generate and read ffmpeg mvs
temp_mvs_vid_file = "tmp/mvs.mp4"; % temporary file from which the mvs are extracted. 
%the file is encoded from original source by x264, saving mvs to it.

% encode orignal file to intermediary file with specific settings (gop size etc)
sub_me = 1; % subme: 7: rd (default), 0: full pel only, 1: qpel sad 1 iter, 2: qpel sad 1 iter
bframes_no = 0;
ref_frames = 0;
key_int = 2; % max interval b/w IDR-frames (aka keyframes)
crf = 30;
x264_execute(orig_input_file_fmt, temp_mvs_vid_file, crf, bframes_no, ref_frames, key_int);

% read mvs from file
temp_mvs_file = "tmp/mvs.txt";
ffmpeg_export_mvs(temp_mvs_vid_file, temp_mvs_file);
[mvs_x, mvs_y, mvs_type, frames_type] = import_mvs(temp_mvs_file, mb_size);

 % export mvs from video and save to mvs_file
 function ffmpeg_export_mvs(video_file, temp_mvs_file)
    codecview_file = strsplit(video_file, '.');
    codecview_file = codecview_file(1);
    ret = system(sprintf("wsl ./FFmpeg/ffmpeg -y -flags2 +export_mvs -i %1$s -vf codecview=mv_type=fp+bp -c:v libx264 -preset ultrafast -crf 0 %2$s_codecview.mp4 > %3$s", video_file, codecview_file, temp_mvs_file));
    if ret ~= 0
        error("ffmpeg exit code is: %d", ret);
    end
 end

end
