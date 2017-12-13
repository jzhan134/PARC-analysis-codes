clear
clc
close all
[file, field, command] = LOAD_PARAMETERS;
fprintf(command)
if ispc
    load(strcat(file.Path,'\Data\',file.File,'_EP.mat'),'EP_Analysis');
elseif isunix
    load(strcat(file.Path,'/Data/',file.File,'_EP.mat'),'EP_Analysis');
end
fpp = file.Frame_per_Cycle;
for ptr_idx = 1:length(EP_Analysis)
% for ptr_idx = [1]
    v_mean = EP_Analysis(ptr_idx).Data;
    time(ptr_idx,:) = v_mean(1,:);
    displacement(ptr_idx,:) = v_mean(2,:);
    velocity(ptr_idx,:) = v_mean(3,:);
    EP(ptr_idx,:) = v_mean(4,:);
end

for i = 1:size(time,1)
    fig1 = figure(1); %displacement
    plot(time(i,:),displacement(i,:)-mean(displacement(i,:)),'.','color',file.Color_code(i,:));
    xlabel(' Time (s)')
    ylabel('Trajectory(\mum)')
    axis([0 0.5 -40 40])
    
    fig2 = figure(2); %velocity
    plot(time(i,:),velocity(i,:),'.','color',file.Color_code(i,:));
    xlabel('Time (s)')
    ylabel('Velocity(\mum/s)')
    axis([0 0.5 -1000 1000])
    
    saveas(fig1,strcat(file.Path,'/Figure/',file.File,'_',num2str(i),'_traj.bmp'));
    saveas(fig2,strcat(file.Path,'/Figure/',file.File,'_',num2str(i),'_velocity.bmp'));
end