% v_mean data structure:
%   (1) time in each period
%   (2) displacement from edge (um)
%   (3) velocity (um/s)
%   (4) EP field
%   (5) DEP field
clear
clc
close all
[file, field, command] = LOAD_PARAMETERS;
fprintf(command)
if ispc
    load(strcat(file.Path,'\Data\',file.File,'.mat'),'Traj');
elseif isunix
    load(strcat(file.Path,'/Data/',file.File,'.mat'),'Traj');
end
fpp = file.Frame_per_Cycle;
file_idx = 'NaN';
for ptr_idx = 1:length(Traj)
% for ptr_idx = [1]

    trajectory = Traj(ptr_idx).Trajectory;
    
    % subtract net drift, and then average displacement of each time point over cycles
    mean_displacement = mean(trajectory);
    traj_single_summary = [];
    while ~isempty(trajectory)
        traj_single_cycle = trajectory(1:file.Frame_per_Cycle);
        traj_single_cycle = traj_single_cycle - mean(traj_single_cycle) + mean_displacement;
        traj_single_summary = cat(1, traj_single_summary, traj_single_cycle);
        trajectory(1:file.Frame_per_Cycle) = [];
    end
    traj_single = mean(traj_single_summary,1);
    
    %% Use the first particle to find the phase lag in each video file
    if strcmp(file_idx, Traj(ptr_idx).Video_idx) == 0
        file_idx = Traj(ptr_idx).Video_idx;
        [v_mean, curr_delay,e_field] = FIT_FIELD_PHASE('y',traj_single, file, field, 0);
    else
        [v_mean, ~, ~] = FIT_FIELD_PHASE('n',traj_single, file, field, curr_delay);
    end
    
    %% Sort the data to remove the phase lag
    for i = 2:length(v_mean(4,:))
        if (v_mean(4,i)*v_mean(4,i-1) <= 0 && v_mean(4,i) >= 0)
            idx = i;
            break;
        else
            idx = 1;
        end
    end
%     v_mean(2:end,:) = [v_mean(2:end,idx:end), v_mean(2:end,1:idx-1)];
%     e_field = [e_field(idx:end), v_mean(1:idx-1)];
    
    %% Plot outcomes
    % I. Trajectory & Electric Field
    fig1 = figure(1);
    hold on
    yyaxis left
    plot(v_mean(1,:),v_mean(2,:)-mean(v_mean(2,:)),'.','color',file.Color_code(ptr_idx,:));
    xlabel(' Time (s)')
    ylabel('Trajectory(\mum)')
    ax = gca;
    ax.YColor= 'k';
    if ptr_idx == 1
        yyaxis right
        plot(v_mean(1,:), e_field,'k-');
        ax = gca;
        ax.YColor= 'k';
        ylabel('V_{pp}/d_g (V/\mum)')
    end
    hold off

    % II. Mean Velocity & Electric Field
    fig2 = figure(2);
    hold on
    yyaxis left
    plot(v_mean(1,:),v_mean(3,:),'*','color',file.Color_code(ptr_idx,:))
    ylabel('Velocity (\mum/s)')
    ax = gca;
    ax.YColor= 'k';
    if ptr_idx == 1
        yyaxis right
        plot(v_mean(1,:),e_field,'k-')
        ylabel('V_{pp}/d_g (V/\mum)')
        xlabel('Time (s)')
        ax = gca;
        ax.YColor= 'k';
    end
    title('Mean Velocity & V_{pp}/d_g')
    hold off

    % III. Mobility
    if field.Type == 'sq'
        fig3 = figure(3);
        hold on
        plot(mod(v_mean(1,:),0.5/field.Freq),v_mean(3,:)./v_mean(4,:),...
            '*','color',file.Color_code(ptr_idx,:)) % mean velocity versus time
        xlabel('Time (s)')
        ylabel('Mobility (\mum/s / V/\mum)')
        title('Mobility & V_{pp}/d_g')
    else
        fig3 = figure(3);
        hold on
        plot(v_mean(4,:),v_mean(3,:),'*','color',file.Color_code(ptr_idx,:)) % mean velocity versus time
        xlabel('Electric Field (V/\mum)')
        ylabel('Velocity (\mum/s)')
%         title('Mobility & V_{pp}/d_g')
    end
    EP_Analysis(ptr_idx).Data = v_mean;
    EP_Analysis(ptr_idx).EField = e_field;
    clear v_data v_mean
end

% % Output data
if ispc
    saveas(fig1,strcat(file.Path,'\Figure\',file.File,'_X','.bmp'));
    saveas(fig2,strcat(file.Path,'\Figure\',file.File,'_V','.bmp'));
    saveas(fig3,strcat(file.Path,'\Figure\',file.File,'_Mu','.bmp'));
    save(strcat(file.Path,'\Data\',file.File,'_EP.mat'),'EP_Analysis');
elseif isunix
    saveas(fig1,strcat(file.Path,'/Figure/',file.File,'_X','.bmp'));
    saveas(fig2,strcat(file.Path,'/Figure/',file.File,'_V','.bmp'));
    saveas(fig3,strcat(file.Path,'/Figure/',file.File,'_Mu','.bmp'));
    save(strcat(file.Path,'/Data/',file.File,'_EP.mat'),'EP_Analysis');
end