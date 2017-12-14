function [x_data,curr_delay,e_field] = FIT_FIELD_PHASE(check,x, file, field,curr_delay)
    % x_data data structure (one entry less than displacement array):
    %   1. Absolute time
    %   2. Displacement
    %   3. Velocity
    
    Time = linspace(0,file.Frame_per_Cycle/file.Fps/file.Acceleration,file.Frame_per_Cycle-1);
    Displacement = (x(2:end) + x(1:end-1))/2; % displacement (um)
    Velocity = diff(x)*file.Fps*file.Acceleration; % velocity in real time (um/s)
    
    % Find best delay fit
    if check == 'y'
        fit_parameter = NaN*ones(1,400);
        for i = 1:400
            delay = -2+0.01*i;
            [EP, ~,~] = EP_DEP_factor(field, file, Time,Displacement,delay);
            if mean(Velocity./EP) >= 0
                fit_parameter(i) = std(Velocity./EP);
            else
                fit_parameter(i) = NaN;
            end
        end
        [~,idx] = min(fit_parameter);
        curr_delay = -2+0.01*idx;
        [EP, ~] = EP_DEP_factor(field,file, Time,Displacement,curr_delay);
        
        % Allow manual change of phase
        while(true)
            % Visually check the time phase
            figure(4)
            clf
            hold on
            plot(Time,Velocity,'r*') % Velocity versus period time
            ylabel('Velocity (\mum/s)')
            yyaxis right
            plot(Time,EP,'k-') % electric field versus time
            ylabel('V_{pp}/d_g (V/\mum)')
            xlabel('Time (s)')
            hold off
            
            % Manual change of phase
            buff = input('Manually change the phase (press ENTER to continue)?');
            if isempty(buff)
                break;
            end
            curr_delay = curr_delay+buff;
            [EP, ~] = EP_DEP_factor(field,file, Time,Displacement,curr_delay);
        end
        close(figure(4))
    end
    
    % Store field with correct phase
    [EP, DEP,e_field] = EP_DEP_factor(field,file, Time, Displacement,curr_delay);
    x_data = cat(1, Time, Displacement, Velocity, EP, DEP);
end