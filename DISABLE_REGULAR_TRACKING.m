function [displacement,displacement_movie] = REGULAR_TRACKING(file, ptr_idx, color_code)
    %% Parameters    
    % Particle indentification method
    operation = 'g'; % b: brightness, g: gradient

    % Image parameters
    thresh = 240; % Minimum brightness of the pixels representing particles
    obj = 10;
    mag = 1.6;
    bin = 4;
    scale = 1214*(bin/8)*(40/obj)*(1/mag)/1000; %um/pixel
    fwidth = 1344/bin;
    fheight = 1024/bin;
    
    % video & output parameters
    v = VideoReader(strcat(file.Path,'\',file.Full_file,'.avi'));
    v.CurrentTime = file.Start;
    displacement = zeros(1,file.Duration*file.Fps); %displacement from left electrode edge
    displacement_movie = zeros(2,file.Duration*file.Fps); %displacement from left frame edge
    curr_frame = readFrame(v);% curr_frame(height,width)
    
    %% Pick the particle from the first frame
    figure(1)
    clf
    imshow(curr_frame)
    fprintf('Pick particle in the first frame...\n')
    [x,y] = ginput(); % x:width from left % y: height from top
    particle_prev = [y,x];
    
    
    %% Find particle center in each frame
    for f = 1:file.Duration*file.Fps
        [bound,edge] = Find_Current_Bound(curr_frame,x,y,fheight,scale);
        % The first frame is already read to pick the particle, so read another
        % frame from the second frame
        if f ~= 1
            curr_frame = readFrame(v);
        end

        % Trim the frame into a window region, the region is a box with the
        % particle from the previous frame at the center
        Window = curr_frame(bound.top:bound.bottom,bound.left:bound.right);

        % Find all pixels in the windows that meet the criteria
        if operation == 'g'
            [h_temp, w_temp]= Find_particle_Gradient(cast(Window,'single'));
        elseif operation == 'b'
            [h_temp, w_temp] = find(Window >= thresh);
        end

        % Comb pixels into cluster(s), which each corresponds to a particle
        particle_center = Check_Multiple_Particle(curr_frame,bound, h_temp, w_temp,particle_prev,f/file.Fps);

        % Reverse the location from window to the whole frame
        x = particle_center(2) + bound.left;
        y = particle_center(1) + bound.top; 
%         rectangle_plot_x = [bound.left,bound.right,bound.right,bound.left,bound.left];
%         rectangle_plot_y = [bound.top,bound.top,bound.bottom,bound.bottom,bound.top];
%         hold on
%         imshow(curr_frame)
%         plot(x,y,'rx')
%         plot(rectangle_plot_x,rectangle_plot_y,'b-')
%         hold off
        % Write data into output files
        displacement(f) = (x-edge.left)*scale;
        displacement_movie(:,f) = [x;y];
        particle_prev = particle_center;
    end

    % Raw trajectory plot
    fig = figure(2);
    plot(1/file.Fps:1/file.Fps:file.Duration,displacement,'.-','color',color_code(ptr_idx,:))
    title('Displacement vs Time')
    ylabel('Displacement from Electrode Edge (\mum)')
    xlabel('Time (s)');
%     saveas(fig,strcat(file.Path,'\Figure\',file.File,'_Trajectory_',num2str(ptr_idx),'.bmp'));
    pause(1);
    figure(1)
    clf
    figure(2)
    clf
end