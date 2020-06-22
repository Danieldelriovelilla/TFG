function Cylinder(Centers, i, j, z0)

    R = 25;
    %x0 = 0; y0 = 0; z0 = 10;
    h = 250;
    [x,y,z] = cylinder(R);
    x = x + Centers{i,j}(1);
    y = y + Centers{i,j}(2);
    z = z*h + z0;
    
    %Plot
    c = surf(x,y,z);
    c.FaceAlpha = 0.5;         % remove the transparency
    c.FaceColor = 'interp';    % set the face colors to be interpolated
    c.LineStyle = 'none';      % remove the lines
    colormap(white) 
    l = light('Position',[-0.4 0.2 0.9],'Style','infinite');
    lighting gouraud;
    %axis equal off;
    material shiny;
    axis([-100 900 -100 900 -100 300])
    
    hold off
end