function [Coor, Grid, Centers] = Grid_Processor(A, B, C, D, Nex, Ney)

    %Contour lines
    Coor = [A ; B; D; C];

    Nnx = Nex + 1;
    Nny = Ney + 1;

    L1 = [linspace(A(1),B(1),Nny);linspace(A(2),B(2),Nny)]; L1(3,:) = 0;
    L2 = [linspace(A(1),C(1),Nnx);linspace(A(2),C(2),Nnx)]; L2(3,:) = 0;
    L3 = [linspace(B(1),D(1),Nnx);linspace(B(2),D(2),Nnx)]; L3(3,:) = 0;
    L4 = [linspace(C(1),D(1),Nny);linspace(C(2),D(2),Nny)]; L4(3,:) = 0;

    for i = 1:Nny
        Nodey{1,i} = [L1(:,i)'];
        Nodey{2,i} = [L4(:,i)'];
    end
    for i = 1:Nnx
        Nodex{1,i} = [L2(:,i)'];
        Nodex{2,i} = [L3(:,i)'];
    end

    %Element nodes
    for i = 1:Nnx
        for j = 1:Nny
            Grid{i,j} = [InterX([Nodex{1,i}' Nodex{2,i}'],...
                                [Nodey{1,j}' Nodey{2,j}'])', 0];
        end
    end

    % Element centers
    for i = 1:Nex
        for j = 1:Ney
            Centers{i,j} = [(Grid{i+1,j}(1)-Grid{i,j}(1))/2+Grid{i,j}(1),...
                            (Grid{i,j+1}(2)-Grid{i,j}(2))/2+Grid{i,j}(2),0];
        end
    end

end