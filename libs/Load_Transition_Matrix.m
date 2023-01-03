


function Transition_Matrix = Load_Transition_Matrix(N_Clusters, Cluster_Curr, file_name )

    show_fig=0;
    Transition_Matrix = [];
 
    if exist(file_name, 'file') == 2
        %my_data = matfile('TrMat.mat')
        %Transition_Matrix = my_data.Transition_Matrix;
        my_data = csvread(file_name);
        
        [nr ncc] = size(my_data);
        
        if(nr ~= N_Clusters)
           disp ('Error in N_Clusters')
           disp ('Returning an empty matrix')
           return
        end
        
        Transition_Matrix=zeros(N_Clusters, N_Clusters,  ncc /nr);
        
        for i = 1 : ncc /nr 
            
            Transition_Matrix(:,:,i) =  my_data(1:nr,  N_Clusters*(i-1)+1 : N_Clusters*i);
           % Transition_Matrix(:,:,i) =  bsxfun(@times, Transition_Matrix(:,:,i), 1./(sum(Transition_Matrix(:,:,i), 2)));
            Transition_Matrix(:,:,i)= Normalize_Mat_rows(Transition_Matrix(:,:,i));
        end
        
        %A partire dalla Transition Matrix lev 1 si diminuscono le transizioni 
        % verso i cluster con corrente maggiore in relazione alla corrente
        % erogata (eventualmente in relazione al pain)
        
        Total_Curr_Cluster = sum(Cluster_Curr);
        
        %modifica la transizione rispetto alla corrente dei cluster
        %alpha = 5.0e-3
        alpha = 0.05;
        
        beta = 5*alpha;
        indx =1;
        N_samples = 20;
        Pain = zeros(1, N_samples);
        %x_vals = 0:0.5:10
        x_vals = linspace(0, 10, N_samples);
       
        if(show_fig==1)
            
            while indx <= N_samples

                Pain(indx) = 1 - 1/(1+exp(-alpha*x_vals(indx)+beta));
                if(show_fig==1)
                    disp([num2str(x_vals(indx)),'p=', num2str(Pain(indx),'%10.5e')]);
                end
                indx = indx+1;
            end
            
            figure(1)
            clf
            plot( x_vals(1:N_samples), Pain)
        end
    else
         disp ('Error: I cannot find file:', file_name )
        
    end
end

function Transition_Matrix = Normalize_Mat_rows( Transition_Matrix)

    [nr nc]=size(Transition_Matrix);

    if(size(size(Transition_Matrix),2)==2)
        
        R_sum = sum(Transition_Matrix');
        
           for i = 1: nr
               
                Transition_Matrix(i,:) = Transition_Matrix(i,:) ./ R_sum(i);
               
           end

    else
       disp('Error: matrix was expected to have dim equal to 2')
        
    end
    

end


