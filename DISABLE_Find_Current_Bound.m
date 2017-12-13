function [bound,edge] = Find_Current_Bound(curr_frame,x,y,fheight,scale)
    wh = 5;
    ww = 35;
    bound = struct('top',[],'bottom',[],'left',[],'right',[]);
    edge = struct('top',[],'bottom',[],'left',[],'right',[]);
    % Find top/bottom bound
    if (round(y) - wh) < 1
        bound.top = 1;
    else
        bound.top = round(y) - wh;
    end
    if (round(y) + wh >= fheight)
        bound.bottom = fheight;
    else
        bound.bottom = round(y) + wh;
    end
    % Find electrode edges
    edge.left = find(mean(curr_frame(bound.top:bound.bottom,:)) > 100,1);
%     edge.left = 1;
    edge.right = edge.left + round(300/scale);
    % Find left/right bound
    if (round(x) - ww < edge.left)
        bound.left = edge.left;
    else
        bound.left = round(x) - ww;
    end
    if (round(x) + ww > edge.right)
        bound.right = edge.right;
    else
        bound.right = round(x) + ww;
    end
end