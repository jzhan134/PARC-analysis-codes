% The current script reads a single movie file and output a movie with
% desired frame rate and time frame into the same folder
clear
clc
close all

folder_path = '/home/aledonbde/Desktop/Opposite direction motion';
file = '2V_2Hz_II';
target_frame_rate = 54;

if ispc
    video_reader_name = [folder_path,'\',file,'.avi'];
    video_writer_name = [folder_path,'\',file,'_',num2str(target_frame_rate),'fps.avi'];
elseif isunix
    video_reader_name = [folder_path,'/',file,'.avi'];
    video_writer_name = [folder_path,'/',file,'_',num2str(target_frame_rate),'fps.avi'];
end
v0 = VideoReader(video_reader_name);
v1 = VideoWriter(video_writer_name);
v1.FrameRate = target_frame_rate;
open(v1);
f = 1;
%  while hasFrame(v0)
while f <= 54*15
    video = readFrame(v0);
    writeVideo(v1,video);
    f = f+1;
end
close(v1);


% Find all items in the folder
% list = dir(folder_path);
% % Create a raw data subfolder
% raw_data_path = strcat(folder_path,'\raw_data');
% if (~exist(raw_data_path))
%     mkdir(raw_data_path);
% end
% for i = 3:size(list,1)
%     if (list(i).isdir == false)
%         file_name = list(i).name;
%         movefile(strcat(folder_path,'\',file_name),raw_data_path);
%         if strcmp(file_name(end-2:end),'avi')
% 
%             file_handle = file_name(1:end-4);
%             video_reader_name = strcat(folder_path,'\raw_data\',file_handle,'.avi');
%             video_writer_name = strcat(folder_path,'\',file_handle,'.avi');
%             v0 = VideoReader(video_reader_name);
%             v1 = VideoWriter(video_writer_name);
%             v1.FrameRate = 28;
%             open(v1);
%             while hasFrame(v0)
%                 video = readFrame(v0);
%                 writeVideo(v1,video);
%             end
%             close(v1);
%             clear v0;
%         end
%     end
% end
% v0.NumberOfFrames