%-   DESCRIPTION   -%
%{
    Function wich extract the data in a .rpt file
%}
function [Data] = rpt_Reader(fName)
    % OPEN FILE
    fileID = fopen(fName);
    % PROCESS
    dline = 0;
    tline = 0;
    while ~feof(fileID)
        s = fgets(fileID);
        [data, ncols, errmsg, nxtindex]= sscanf(s, '%f');
        if ~isempty(data)   %If data is not empty
            dline = dline+1;
            Data(dline,:) = data;
        else
            tline = tline + 1;
            t{tline,1} = s;
        end
    end 
    fclose(fileID);
end