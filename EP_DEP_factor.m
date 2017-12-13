function [EP, DEP,e_field] = EP_DEP_factor(field, file, t, x, delay)
    voltage = field.Volt*40;
    electrode_gap = field.gap_width;
    freq = field.Freq;
    type = field.Type;
    fps = file.Fps;
    if type == 'sq'
        e_field = (voltage/electrode_gap)*square((t+delay)*2*pi*freq);
    else
        e_field = (voltage/electrode_gap)*sin((freq)*(t - 1/(fps/freq) + delay)*2*pi);
    end
    y = 5;
    d = electrode_gap;
    x = 0 : 100;
    x = x-d/2;
    % EP
    xx = pi*(x+d)/(2*d) + pi/4;
    yy = pi*y/(2*d);
    Ex = (1/pi).*(atan(sin(xx)/sinh(yy)) - atan(cos(xx)/sinh(yy)));
    EP = e_field.*Ex;
    % DEP
    xx = pi*(x-0.001+d)/(2*d) + pi/4;
    yy = pi*y/(2*d);
    Ex = (1/pi).*(atan(sin(xx)/sinh(yy)) - atan(cos(xx)/sinh(yy)));
    Ey = (1/2)*(1/pi).*log((cos(xx)+cosh(yy)).*(sin(xx) + cosh(yy))./(cosh(yy)-cos(xx))./(cosh(yy) - sin(xx)));
    E1 = sqrt(Ex.^2 + Ey.^2);
    xx = pi*(x+0.001+d)/(2*d) + pi/4;
    yy = pi*y/(2*d);
    Ex = (1/pi).*(atan(sin(xx)/sinh(yy)) - atan(cos(xx)/sinh(yy)));
    Ey = (1/2)*(1/pi).*log((cos(xx)+cosh(yy)).*(sin(xx) + cosh(yy))./(cosh(yy)-cos(xx))./(cosh(yy) - sin(xx)));
    E2 = sqrt(Ex.^2 + Ey.^2);
    DEP = ((300/300).^2.*(E2-E1)/0.002);
end