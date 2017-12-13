function [displacement,displacement_movie] = HIGH_SPEED_TRACKING(file, ptr_idx)
    %% Parameters  
    % Image parameters
    ptr_sz = 20; % # of pixel (20 for 2.34um silica)
    thresh = 200; % Minimum brightness of the pixels representing particles
    win_h = 0.5*ptr_sz;
    win_w = ptr_sz;
    obj = 10;
    mag = 1;
    scale = 1710/8*(40/obj)*(1/mag)/1000; %um/pixel
    scale = 0.9; %0.9 for 300, 0.2 for 100
    % video & output parameters
    v = VideoReader(strcat(file.Path,'/',file.Full_file,'.avi'));
    v.CurrentTime = file.Start;
    displacement = zeros(1,file.Frame_per_Cycle*file.Tot_Cycle); %displacement from left electrode edge
    displacement_movie = zeros(2,file.Frame_per_Cycle*file.Tot_Cycle); %displacement from left frame edge
    x_axis = linspace(0,file.Tot_Time,file.Frame_per_Cycle*file.Tot_Cycle);
    
    figure(1)
    clf
    %% Find particle center in each frame
    for f = 1:file.Frame_per_Cycle*file.Tot_Cycle
        curr_frame = readFrame(v);
        %% In the first frame, indentify the particle and edge locations
        if f == 1
            imshow(curr_frame)
            title('Pick particle in the first frame')
            [x,y] = ginput(); % x:width from left % y: height from top
            wide_left = max(round(x)-ptr_sz,0);
            wide_right =min(round(x)+ptr_sz,size(curr_frame,1));
            height_top = max(round(y)-ptr_sz,0);
            height_bottom = min(round(y)+ptr_sz,size(curr_frame,2));
            Window = curr_frame(height_top:height_bottom,wide_left:wide_right,1);
            [y_idx,x_idx] = find(Window >= thresh);
            w = mean(x_idx) + wide_left-1;
            h = mean(y_idx) + height_top-1;
            hold on
            plot(w,h,'rx')
            title('Pick electrode edge')
            [edge,~] = ginput();
            if edge <= 0
                edge = 1;
            elseif edge >= size(curr_frame,1)
                edge = size(curr_frame,1);
            end
        end
        
        %% Focus on the area around the particle in the previous frame and find the new location
        wide_left = max(round(w)-win_w,0);
        wide_right =min(round(w)+win_w,size(curr_frame,1));
        height_top = max(round(h)-win_h,0);
        height_bottom = min(round(h)+win_h,size(curr_frame,2));
        Window = curr_frame(height_top:height_bottom,wide_left:wide_right,1);        
        [y_idx,x_idx] = find(Window >= thresh);
        
        % manually pick particle center
        if isempty(y_idx) 
            figure(2)
            imshow(Window)
            title(sprintf('t: %.2f',f/file.Fps));
            [x_idx,y_idx] = ginput();
        end
        w = mean(x_idx) + wide_left -1;
        h = mean(y_idx) + height_top -1;
        
        % Write data into output files
        displacement(f) = (edge-w)*(-1)^(round(edge/size(curr_frame,2))+1)*scale;
        displacement_movie(:,f) = [w;h];
        
        % show video frame every 9 frames
        if mod(f,9) == 0
            figure(1)
            imshow(curr_frame)
            title(sprintf('t: %.0fs',f/file.Fps));
            hold on
            plot(w,h,'rx');
            hold off
            drawnow;
        end
    end

    % Raw trajectory plot
    fig = figure(2);
    plot(x_axis,displacement,'.-','color',file.Color_code(ptr_idx,:))
    title('Displacement vs Time')
    ylabel('Displacement from Electrode Edge (\mum)')
    xlabel('Time (s)');
    saveas(fig,strcat(file.Path,'\Figure\',file.File,'_Trajectory_',num2str(ptr_idx),'.bmp'));
end