clear
clc
close all

% Load all information about field and movie file
[file, field, command] = LOAD_PARAMETERS;

% Load the data file or create one if it does not exist
if ispc && exist(strcat(file.Path,'\Data\',file.File,'.mat'),'file') ~= 0
    load(strcat(file.Path,'\Data\',file.File,'.mat'));
elseif isunix && exist(strcat(file.Path,'/Data/',file.File,'.mat'),'file')
    load(strcat(file.Path,'/Data/',file.File,'.mat'));
else
    Traj = struct([]);
end

% Display the current file and field information 
fprintf(command);
fprintf(['\tTotal Traj#:\t%.0f\n',...
    '------------------------------------------------\n'],size(Traj,2));

% select a movie appendix or opt-out if no input
while (true)
    file_idx = input('Select a movie appendix(0: no appendix, ENTER: exit): ','s');
    if isempty (file_idx)
        break;
    elseif file_idx == '0'
        file.Full_file = file.File;
    else
        file.Full_file = strcat(file.File,'_',file_idx);
    end
    clc;

% assign an index to the next particle being tracked
    while (true)
        fprintf(command);
        fprintf(['\tTotal Traj#:\t%.0f\n',...
            '------------------------------------------------\n'],size(Traj,2));
        fprintf('Current movie chosen:\t %s\n',file.Full_file);
        ptr_idx = input('Type a particle index (ENTER: exit):');
        
        if (isempty(ptr_idx))
            break; % allow opt-out to movie selection
        end
        clc
        
        fprintf(command);
        fprintf(['\tTotal Traj#:\t%.0f\n',...
            '------------------------------------------------\n'],size(Traj,2));
        fprintf('Current movie chosen:\t %s\n',file.Full_file);
        fprintf('Current particle chosen:\t %.0f\n',ptr_idx);
        
        % record the source of the particle
        Traj(ptr_idx).Video_idx = file_idx; 
        
        % tracking script for low and high frame rate video
    %             [Traj(ptr_idx).Trajectory, Traj(ptr_idx).Trajectory_Movie] = ...
    %                 REGULAR_TRACKING(file, ptr_idx, color_code);
        [Traj(ptr_idx).Trajectory, Traj(ptr_idx).Trajectory_Movie] = ...
            HIGH_SPEED_TRACKING(file, ptr_idx);
        
% Save the data file
        if ispc
            save(strcat(file.Path,'\Data\',file.File,'.mat'),'Traj');
        elseif isunix
            save(strcat(file.Path,'/Data/',file.File,'.mat'),'Traj');
        end
        input(sprintf('particle %.0d has been saved, press ENTER to continue...\n',ptr_idx));
        clc
    end
end



% % Manual trigger for video capture
% trigger(vid);
% 
% % Get image data
% imat = getdata(vid);
% frametemp = bpass(imat,1,psize); % bandpass filter
% pk = pkfnd(frametemp,thresh,11); % find peaks
% cnt = cntrd(frametemp,pk,15,0); % identify centers
% 
% % particle centers scaled
% xyz = scale.*cnt;
% % number of particles found
% pnum = size(xyz,1);
% xm = mean(xyz(:,1));
% ym = mean(xyz(:,2));