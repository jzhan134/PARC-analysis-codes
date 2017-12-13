%% Adjustable parameters
clear
clc
clf
LOAD_PARAMETER;
load(strcat(file.Path,'\Data\',file.File,'.mat'),'Traj');
fpp = Field.Period*file.Fps;
parameter = struct(...
    'Volt',field.Volt*40, ...
    'Period',Field.Period, ...
    'Freq',field.Freq, ...
    'Type',field.Type, ...
    'fps',file.Fps);
final_DEP = [];
final_EP = [];
for ptr_idx = 1:length(Traj)
    % Load the particle trajectory of a particle
    trajectory = Traj(ptr_idx).Trajectory;

    % Find the phase for the first particle in each video file
    % The rest particles in the same video file use the same phase
    if exist('file_idx') == false || file_idx ~= Traj(ptr_idx).Video_idx
        file_idx = Traj(ptr_idx).Video_idx;
        [v_data, curr_delay] = ...
            Particle_Dynamics_Function('y',trajectory, parameter,0);
    else
        [v_data, ~] = ...
            Particle_Dynamics_Function('n',trajectory, parameter,curr_delay);
    end
    for i = 1:10
        DEP_temp(1,i) = i/2-(1/2/2); %ime
        DEP_temp(2,i) = mean(displacement((i-1)*fps*period+1:i*fps*period)); %displacement
        EP_temp((i-1)*fps*period+1:i*fps*period) = displacement((i-1)*fps*period+1:i*fps*period) - DEP_temp(2,i);
    end
    DEP(1,:) = (DEP_temp(1,1:end-1) + DEP_temp(1,2:end))/2; % Time 
    DEP(2,:) = (DEP_temp(2,1:end-1) + DEP_temp(2,2:end))/2; % Displacement
    DEP(3,:) = diff(DEP_temp(2,:))*fps; %velocity
    [~,DEP(4,:)] = EP_DEP_factor(parameter,DEP(1,:),DEP(2,:),0);
    DEP(5,:) = DEP(3,:)./DEP(4,:);
    
    EP(1,:) = t(1:end-1) + t(1)/2; % time
    EP(2,:) = (displacement(2:end) + displacement(1:end-1))./2; %absolue displacement
    EP(3,:) = diff(EP_temp)*fps; % velocity
    [EP(4,:),~] = EP_DEP_factor(parameter,EP(1,:),EP(2,:),delay);
    EP(5,:) = EP(3,:)./EP(4,:);
    
    fig = figure(ptr_idx*10+1); % disp
    subplot(2,1,1)
    title('Displacement')
    plot(t,displacement,'-','color',color_code(ptr_idx,:))
    hold on
    plot(DEP(1,:),DEP(2,:),'r.-')
    hold off
    legend('total trajectory','mean trajectory')
    xlabel('time')
    ylabel('distance from edge')
    subplot(2,1,2)
    plot(t,EP_temp,'b-')
    xlabel('time')
    ylabel('oscillatory displacement')
    saveas(fig,strcat('C:\Users\aleonbde\Desktop\171018 AlOx Lecithin\1.0%\EP+DEP model Figures\',num2str(ptr_idx),'.bmp'));
    close(fig)
    
    figure(1) %velo
    title('mean velocity versus DEP force')
    hold on
    plot(DEP(4,:),DEP(3,:),'*','color',color_code(ptr_idx,:))
    final_DEP = cat(2,final_DEP,[DEP(4,:);DEP(3,:)]);
    hold off
    xlabel('DEP force')
    ylabel('mean velocity')
    
    figure(2) %velo
    hold on
    plot(EP(4,:),EP(3,:),'*','color',color_code(ptr_idx,:))
    final_EP = cat(2,final_EP,[EP(4,:);EP(3,:)]);
    ax = gca;
    ax.YColor = 'b';
    xlabel('EP force')
    ylabel('Oscillatory velocity')
    hold off
end
p_DEP = polyfit(final_DEP(1,:),final_DEP(2,:),1);
p_EP = polyfit(final_EP(1,:),final_EP(2,:),1);
figure(1)
x = [-1 1];
hold on
plot(x,x*p_DEP(1)+p_DEP(2),'k-')
hold off
axis([-2.5e-3 2.5e-3,-40 40])
figure(2)
hold on
plot(x,x*p_EP(1),'k-')
hold off
axis([-1 1,-80 80])
epsilon = 1.81e-11;
eta = 0.003;
zeta = p_EP(1)*eta/epsilon*1e-12*1000
a = 10e-6;
fcm = p_DEP(1)*6*eta/epsilon/a^2*1e-24