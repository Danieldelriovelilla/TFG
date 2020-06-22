function Grid_Plot(Coor, Grid, Centers, model, nx, ny)

    %Laminate
    %figure();
    %axis equal off
    %fill3(Coor(:,1),Coor(:,2),Coor(:,3),[0.08,0.08,0.08], 'FaceAlpha', 0.5)
    for i = 1:size(Grid,1)
        plot3([Grid{i,1}(1) Grid{i,end}(1)],[Grid{i,1}(2) Grid{i,end}(2)],[0, 0], 'Color', 'k')
        hold on
    end
    for j = 1:size(Grid,2)
        plot3([Grid{1,j}(1) Grid{end,j}(1)],[Grid{1,j}(2) Grid{end,j}(2)],[0, 0], 'Color', 'k')
    end
    if nx == 0 | ny == 0
        for i = 1:size(Grid,1)-1
            for j = 1:size(Grid,2)-1
                plot3(Centers{i,j}(1), Centers{i,j}(2), Centers{i,j}(3), '.', 'Color', 'r')
            end
        end
    else
        for i = 1:size(Grid,1)-1
            for j = 1:size(Grid,2)-1
                if i<nx | [i==nx& j<=ny]
                    plot3(Centers{i,j}(1), Centers{i,j}(2), Centers{i,j}(3), '.', 'Color', 'b')
                else
                    plot3(Centers{i,j}(1), Centers{i,j}(2), Centers{i,j}(3), '.', 'Color', 'r')
                end
            end
        end
    end
    pdegplot(model,'FaceLabels','off','FaceAlpha',1)
    axis([-100 900 -100 900 -100 300])


end

