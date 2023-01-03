function Reward_Matrix = Load_Energy_Reward_Matrix(N_states, N_actions, file_name )

    
    Reward_Matrix = [];
 
    if exist(file_name, 'file') == 2
       
        my_data = csvread(file_name);
        
        [nr nc] = size(my_data);
        
        if(nr ~= N_states)
           disp ('Error in N_states')
           disp ('Returning an empty matrix')
           return
        end
        
        if(nc ~= N_actions)
           disp ('Error in N_actions')
           disp ('Returning an empty matrix')
           return
        end
        
        Reward_Matrix = my_data

    else
         disp ('Error: I cannot find file:', file_name )
        
    end
end



