function [file, field, command] = LOAD_PARAMETERS
set(0,'DefaultFigureWindowStyle','docked')
warning off
%% File parameters
file.Path = '/home/aledonbde/Desktop';
file.File = '2V_2Hz';

%% Create folders if nonexist
if isunix && exist(strcat(file.Path,'/Figure'),'dir') == 0
    mkdir(strcat(file.Path,'/Figure'));
    mkdir(strcat(file.Path,'/Movie'));
    mkdir(strcat(file.Path,'/Data'));
elseif ispc && exist(strcat(file.Path,'\Figure'),'dir') == 0
    mkdir(strcat(file.Path,'\Figure'));
    mkdir(strcat(file.Path,'\Movie'));
    mkdir(strcat(file.Path,'\Data'));
end
%% Movie (file) parameters
file.Fps = 54; % fps of the movie
file.Acceleration = 10; % slow down ratio of movie fps compared with real fps
file.Start = 0; % time of the start of trajectory tracking
file.Tot_Cycle = 3; % number of cycles to track

%% Dynamics Parameters
% Load the voltage and frequency automatically based on the file name
% The frequency is based on the fps of movie
v_idx = strfind(file.File,'V');
field.Volt = str2double(file.File(1:(v_idx-1)));
if strcmp(file.File(end-2:end),'sin')
    field.Type = 'si';
else
    field.Type = 'sq';
end
freq_idx = strfind(file.File,'Hz');
field.Freq = str2double(file.File((v_idx+2):(freq_idx-1)));
field.gap_width = 300;
file.Tot_Time = file.Tot_Cycle/field.Freq*file.Acceleration;
file.Frame_per_Cycle = file.Fps/field.Freq*file.Acceleration;
command = sprintf(['File parameters:\n',...
    '\tFile name:\t%s',...
    '\n\tTotal cycle:\t%.0f',...
    '\n\tframe/cycle:\t%.0f',...
    '\n\tTotal time:\t%.1fs\n'],...
    file.File, file.Tot_Cycle, file.Frame_per_Cycle,file.Tot_Time);

%% colors for color rendering
file.Color_code = ...
    [255, 0, 0;... %red
    255, 64, 0;... %orange
    255, 192, 0;... %orange
%     255, 255, 0;...%yellow
    0, 125, 0;...%green
    0, 255, 0;...%green
    0, 128, 128;...%cyan
    0, 255, 255;...%cyan
    0, 0, 255;...%blue
    128, 0, 255;...%purple
    255, 0, 255;...%pink
    255, 255, 255;...%pink
    ];
file.Color_code = file.Color_code./255;
end