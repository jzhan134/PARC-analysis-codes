%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electrophoresis movie reader %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Jianli Zhang %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Last edit: 171212 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{

Background:
    Electrophoresis is the particle motion in an electric field under the interaction of the field 
    and the surrounding charges near the particles. The velocity of particle is proportional to the
    field magnitude, and the ratio depends on the particle and medium properties.

	Under the current project, oxidized particles moving in non-aqueous envoironment are studied in 
    order to understand the influence of non-aqueous medium to the particle surface charges. 

Output:
      Maximum of 10 particles can be identified in each case

Currently known constrains:
      Particles should has significant contrast to the background brightness
      Particle being tracked should be at least a particle-radius away from any other particle in
      any frame
      At least one side of the electrode edge has to be identifiable

Movies should be named as "aV_bHz_X.avi" or "aV_bHz_sin_X.avi", where a is the voltage, b is the 
frequency, and X is the file index in roman numbers (I,II,...), "_sin" is added if the field is 
sinusoidal, otherwise the field should be square. 

All files with same condition (voltage and frequency) are analyzed together later. One data file
is created or updated per condition, with each particle as a separate entry in the file. The data
variable is named "Traj", and the file named as <movie_file_name>.mat is saved in "Data" folder.
%}
clear
clc
close all
[file, field, command] = LOAD_PARAMETERS;
% If the trajectory data file already exists for the current movie file, load it and continue edit
if ispc && exist(strcat(file.Path,'\Data\',file.File,'.mat'),'file') ~= 0
    load(strcat(file.Path,'\Data\',file.File,'.mat'));
elseif isunix && exist(strcat(file.Path,'/Data/',file.File,'.mat'),'file')
    load(strcat(file.Path,'/Data/',file.File,'.mat'));
else
    Traj = struct([]);
end
fprintf(command);
fprintf(['\tTotal Traj#:\t%.0f\n',...
    '------------------------------------------------\n'],size(Traj,2));

%% Select a movie file
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
%% Select a particle
    while (true)
        fprintf(command);
        fprintf(['\tTotal Traj#:\t%.0f\n',...
            '------------------------------------------------\n'],size(Traj,2));
        fprintf('Current movie chosen:\t %s\n',file.Full_file);
        ptr_idx = input('Type a particle index (ENTER: exit):');
        if (isempty(ptr_idx))
            break;
        else
            clc
            fprintf(command);
            fprintf(['\tTotal Traj#:\t%.0f\n',...
                '------------------------------------------------\n'],size(Traj,2));
            fprintf('Current movie chosen:\t %s\n',file.Full_file);
            fprintf('Current particle chosen:\t %.0f\n',ptr_idx);
            Traj(ptr_idx).Video_idx = file_idx; % record the source of the particle
%             [Traj(ptr_idx).Trajectory, Traj(ptr_idx).Trajectory_Movie] = =REGULAR_TRACKING(file, ptr_idx, color_code);
            [Traj(ptr_idx).Trajectory, Traj(ptr_idx).Trajectory_Movie] = HIGH_SPEED_TRACKING(file, ptr_idx);
        end
        
%% Save the trajectory of current particle 
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