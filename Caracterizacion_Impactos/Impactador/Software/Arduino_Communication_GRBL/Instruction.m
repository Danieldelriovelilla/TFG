function Instruction(Serial, G_Code)
    
    go = true;
    fprintf(Serial,G_Code);

    while go             

        Serial_Output = fscanf(Serial)

        if (Serial_Output(1:2) == 'ok')
            go=false;
        elseif (Serial_Output(1:5) == 'error')
            go = false;  
        elseif (Serial_Output(1:5) == 'ALARM')
            go = false;
        end

    end

end