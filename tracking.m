%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electrophoresis movie reader %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Jianli Zhang %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Last edit: 171212 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{

Experimental background:

    Electrophoresis is the particle motion in an electric field due to the interaction of the field 
    and the surrounding charges near the particles. The velocity of particle is proportional to the
    field magnitude, and the ratio depends on the particle and medium properties.

	Oxidized particle (currrently alumina with 10um diameter) moving in non-aqueous envoironment 
    (currently hexadecane with AOT as additive) is studied to understand the influence of 
    non-aqueous medium and the addition of additives to the particle surface charges and mobility. 
    A parallel electrode is fabricated to create the electric field, in which the particles are 
    moved accordingly. The motion can be visualized under an inverted microscope, in which the 
    particles can be seen as having a bright center and a dark rim. A digital camera is attached to 
    the microscope, and the motion is recorded at a certain frame rate for a manually set period of
    time.

Experimental data collection:

    Multiple video clips will be recorded and saved for a single field type (frequency, magnitude, 
    and signal type). These files are saved using the following name format:
                                            aV_bHz_c.avi
    where a is the field magnitude shown on the function generator, which is amplified by 40 times
    when used on the electrode; b is the frequency of the field, which could be different from the
    frequency captured by the video due to the different frame rate of movie and camera capture; c
    is the appendix to distinguish between different files under same condition, and Roman letters
    are normally used. This name format applies to the experiments using square signal, and when
    sinuosoidal signal is used, the name format is:
                                            aV_bHz_sin_c.avi


Data processing and code algorithm:

    The script converts up to 10 particles' motions under the same condition into displacement 
    trajectories. These particles can be selected from different files or different time period
    within each file, so long if their conditions are same (field frequency and magnitude). The
    detailed algorithm is as follow.

    The script first identify the condition of the experiment, i.e. the freuqency and amplitude
    automatically from the file name. The code then requires an manual select of the
    appendix to load the corresponding video file, and an assignment of particle index number to 
    save the trajectory. A data file is created for each experiment condition, in which each 
    particle is saved as an separate entry with the following information:
        1. Video_idx: the video source (appendix) of the current particle;
        2. Trajectory: the displacement of the particle measured from the edge of the eletrode;
        3. Trajectory_Movie:  the displacement of the particle measured from the edge of the screen

Current constrains:
      1. Particles should has significant contrast to the background brightness
      2. Particle being tracked should be at least a particle-radius away from any other particle in
      any frame
      3. At least one side of the electrode edge has to be identifiable

%}

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