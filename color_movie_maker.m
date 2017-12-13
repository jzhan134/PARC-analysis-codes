clear
clc
close all
[file, field, command] = LOAD_PARAMETERS;
% If the trajectory data file already exists for the current movie file, load it and continue edit
if ispc && exist(strcat(file.Path,'\Data\',file.File,'.mat'),'file') ~= 0
    load(strcat(file.Path,'\Data\',file.File,'.mat'));
elseif isunix && exist(strcat(file.Path,'/Data/',file.File,'.mat'),'file')
    load(strcat(file.Path,'/Data/',file.File,'.mat'));
end
fprintf(command);

%% Select a movie file
file_idx = input('\nSelect a movie appendix(0: no appendix): ','s');
if file_idx == '0'
    file.Full_file = file.File;
else
    file.Full_file = strcat(file.File,'_',file_idx);
end

video_reader_name = strcat(file.Full_file,'.avi');
if ispc
    v0 = VideoReader(strcat(file.Path,'\',file.Full_file,'.avi'));
    v1 = VideoWriter(strcat(file.Path,'\Movie\',file.Full_file,'.avi'));
elseif isunix
    v0 = VideoReader(strcat(file.Path,'/',file.Full_file,'.avi'));
    v1 = VideoWriter(strcat(file.Path,'/Movie/',file.Full_file,'.avi'));
end
v0.CurrentTime = file.Start;
v1.FrameRate = file.Fps;
open(v1);
Time = 0;
figure(4)
clf
for f = 1:file.Frame_per_Cycle*file.Tot_Cycle
    video = readFrame(v0);
    imshow(video);
    hold on
    for i = 1:size(Traj,2)
        if (strcmp(Traj(i).Video_idx,file_idx) == 1)
            plot(Traj(i).Trajectory_Movie(1,f),Traj(i).Trajectory_Movie(2,f),...
                '.','color',file.Color_code(i,:),'markersize',10)
        end
    end
    this_frame = getframe(gcf);
    hold off
    writeVideo(v1,this_frame.cdata);
    Time = Time + 1/54;
end
close(v1);
clear v0;
close(figure(4))