% h_pxl is the indices from top, w_pxl is the indices from left
% ginput returns:
%       width from left
%       height from top
% particle_center:
%       height from top
%       width from left
% particle:
%       height from top
%       width from left
function [particle] = Check_Multiple_Particle(curr_frame, bound, h_pxl, w_pxl,prev_state,sec)
    particle_center = [];
    % Group pixels into clusters
    while ~isempty(h_pxl)
        pxl_idx = find(sqrt((h_pxl(1)-h_pxl).^2 + (w_pxl(1)-w_pxl).^2) < 10);
        particle_center = cat(2, particle_center, [mean(h_pxl(pxl_idx));mean(w_pxl(pxl_idx))]);
        h_pxl(pxl_idx) = [];
        w_pxl(pxl_idx) = [];
    end
    
    % if no pixels found satisfying the criterion, manually pick a particle
    if isempty(particle_center)
        fprintf('No particle identified t = %.2fs\n',sec);
        figure(1)
        imshow(curr_frame)
        [x_temp, y_temp] = ginput();
        particle = [y_temp-bound.top, x_temp-bound.left];
        
    % if more than one cluster exist, find the one closest to the
    % previous location.
    elseif size(particle_center,2) > 1
        fprintf('Multiple particle identified t = %.2fs\n',sec);
        figure(1)
        imshow(curr_frame)
        [~,idx] = min((particle_center(1,:) - prev_state(1)).^2 + (particle_center(2,:) - prev_state(2)).^2);
        particle_temp = particle_center(:,idx)';
        hold on
        plot(particle_temp(2)+bound.left,particle_temp(1)+bound.top,'b*')
        ask = input('Manual select the correct particle? (y/n)','s');
        if ask == 'y'
            [x_temp, y_temp] = ginput();
            particle = [y_temp-bound.top, x_temp-bound.left];
        else
            particle = particle_temp;
        end
        
    % If only one cluster is found, use this as the true particle location    
    else
        particle = particle_center;
    end
end