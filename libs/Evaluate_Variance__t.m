%function New_State = Pain_State( Pain, time_index, global_time)


function Var_Mat = Evaluate_Variance__t(Global_Mat, p_dim)

[nr, nc, nm] =  size(Global_Mat);

if(p_dim==3)
    Var_Mat = zeros(nr, nc);
    for i = 1:nr
        for j = 1:nc
            
            Var_Mat(i,j) = var(Global_Mat(i,j,:));
            if( isnan(Var_Mat(i,j)))
                Var_Mat(i,j)=0;
            end
        end
    end
    
else
   disp('Warning: Not used for history variance') 
   Var_Mat = var(Global_Mat, p_dim);
end




return


