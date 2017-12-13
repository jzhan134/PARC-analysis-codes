% Calculate vertical standard deviation of each pixel with top and bottom 
% pixel
function [x_temp, y_temp] = Find_particle_Gradient(Window_single)
    var_mat = zeros(size(Window_single,1)-2,size(Window_single,2));
    for w = 1:size(Window_single,2)
        for h = 2:size(Window_single,1)-1
            var_mat(h,w) = mean(std(Window_single(h-1:h+1,w)));
        end
    end
    [x_temp, y_temp] = find(var_mat >= max(max(var_mat))*0.8);
end