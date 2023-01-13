% RL_EnergyModes_URGE

% Experiment for the selection of energy modes according to the Energy Roboception

% The experiment is described in Section "Current Roboception driven behavior" 

% by 

% Agnese Augello,Salvatore Gaglio,Ignazio Infantino,Umberto Maniscalco,Giovanni Pilato,Filippo Vella


function RL_CurrentPain(current_dir)
  
    time_max    = 14400
    Max_Value   = 1
    n_steps     =120 
    N_action_in_a_seq = 10;
    Pain_threshold = 0.5
    N_trials = 1000;
    th=[75, 50, 30, 25];
    threshold_recharge = 98;

    Plot_Flag = true
    Plot_reward = false;
   
    Tau_Charge      =   (3600*2/100)/log(0.5); 
    Tau_Discharge   =   (3600*2/10)/log(0.5);
    time_v          =  linspace(1, time_max, n_steps * N_action_in_a_seq);
   
    Global_Q_State_Action=[]
    Global_State_Value=[]
    
    N_glob_epoch = 5; %1000
    
    N_Actions = 3; %Three possible actions
    N_States = 3; % Three possible states

    N_Clusters = 20; 
 
    % Load Action Clusters
    Cluster_Curr =  Set_Cluster_Curr(N_Clusters); %caricare da file
    
    % Load Transition Matrix
    Transition_Matrix = Load_Current_Transition_Matrix(N_Clusters, Cluster_Curr, './res/Current/TrMat.csv');
      
    if(Plot_reward)
        Plot_Figures(Action_Reward, Action_Cost, N_Actions, n_steps)
    end
    
    % Load Reward Values
    Reward          = Load_Reward_Matrix(N_Clusters, './res/Current/Reward.csv');
    
    Q_State_Action  = zeros(N_States, N_Actions); 
    N_State_Action  = zeros(N_States, N_Actions);
      
    
    for k = 1 : N_glob_epoch
      
        Pain        = zeros(N_trials, n_steps * N_action_in_a_seq);
        Current     = zeros(N_trials, n_steps * N_action_in_a_seq);
        Current_Cluster     = zeros(1, n_steps )  ;
        Current_Cluster(1)  = 1 ;

        alpha = 0.5;
        epsilon =0.2;
        gamma = 0.75;
        Check_Span = 25;
        
        epsilon_trials      = linspace(0.2, 0.1, N_trials);
        alpha_trials        = linspace(0.5, 0.4, N_trials);

        Final_Charge        = zeros(1,N_trials);
        Final_time_index    = zeros(1,N_trials);
        Final_reward        = zeros(1,N_trials);
        
        this_reward_mat     = zeros(N_trials,n_steps);
        Entropy_mat         = zeros(N_trials,n_steps);
        Pain_mat            = zeros(N_trials,n_steps);
        reward_mat          = zeros(N_trials,n_steps);
        State_time_mat      = zeros(N_trials,n_steps);
        working_mode_mat    = zeros(N_trials,n_steps);
        State_Value         = zeros(N_trials, N_States);
        
        conv_condition = 0
        index =1; 
        final_iter = N_trials; 
        i=1;
       
        while (i <= N_trials  && conv_condition==0)

            disp(['Episode ',num2str(i)]);
            Charge = 100; 
            State=1; % NORMAL 
            time_index = 1 ;

            working_mode_mat(i, time_index)  = 1; 
            State_time_mat(i, time_index) = State;  
            Value_time(time_index) = 0;
            cluster_vs_time(time_index) = 1; %it starts from first cluster
            Pain(1)=0;
            Current(1)=1;

            action = Choose_Action_Greedy(Q_State_Action, State, epsilon_trials(i), N_Actions);

            for j = 2 : N_action_in_a_seq

                indx =  j;
                Current(indx) = Cluster_Curr (j, Current_Cluster(1)) ; 
                Pain(indx) = CurrentPain_Somatosensory(Current(indx), Pain_threshold,  Pain(indx-1), Max_Value, time_v(indx), time_v(indx-1), Tau_Charge, Tau_Discharge);
    
            end

            time_index=2;
            reward =0;
            
            while time_index <= n_steps && reward > -100

                %increment the occurrences of the couple <state, action>
                N_State_Action(State, action)= N_State_Action(State, action) + 1 ;

                [reward, this_reward_mat(i, time_index), Entropy_mat(i,time_index)] = Calculate_Reward_State_Action_with_Pain(State, Current_Cluster(time_index-1), Reward, Pain, time_index, N_action_in_a_seq,  cluster_vs_time, N_Clusters);

                reward_mat(i, time_index) = reward;
                
                Current_Cluster(time_index) = Cluster_Transition(Transition_Matrix, Current_Cluster(time_index-1),  working_mode_mat(i, time_index-1) );
    
                for j = 1 : N_action_in_a_seq

                    indx = (time_index-1) * N_action_in_a_seq + j;
                    Current(indx) = Cluster_Curr (j, Current_Cluster(time_index)) ;
                   
                    Pain(indx) = CurrentPain_Somatosensory(Current(indx), Pain_threshold,  Pain(indx-1), Max_Value, time_v(indx), time_v(indx-1), Tau_Charge, Tau_Discharge);
 
                end

                Pain_mat(i, time_index) = Pain(indx);
                
                %check condition for extreme pain
                reward = Check_Pain_Threshold( Pain_mat, i , time_index, reward);

                New_State = Pain_State( Pain, time_index, indx);
               
                %%according the current pain state and Q matrix the new
                %%action is chosen
                new_action = Choose_Action_Greedy(Q_State_Action, New_State, epsilon_trials(i), N_Actions);

                working_mode_mat(i, time_index) = new_action; 

                Q_State_Action (State, action) = Q_State_Action(State, action) + (reward + gamma * Q_State_Action(New_State, new_action)-  Q_State_Action (State, action))/i; %alpha has been changed bt 1/t for robbins monro sequence

                %Update
                State = New_State;
                action = new_action;
                State_time_mat  (i, time_index)= State;
                cluster_vs_time (time_index)=  Current_Cluster(time_index);

                if(time_index>1)
                    Value_time(time_index) = Value_time(time_index-1)+ reward;
                else
                    Value_time(1) =  reward;
                end

                time_index = time_index+1;

            end

            Final_reward(i) = reward;
            Final_Charge(i) = Charge;
            Final_time_index(i) = time_index;

            N_State_Action_p =  bsxfun(@times, N_State_Action, 1./(sum(N_State_Action, 2)));

            for is= 1:N_States
                for ja =1:N_Actions
                    State_Value(i,is) = State_Value(i, is) +  N_State_Action_p(is,ja) * Q_State_Action(is,ja);
                end
            end

            
            conv_condition = Check_Convergence(Check_Span, State_Value, N_trials, i);

            i = i+1;
        end
        
        i=i-1;
        final_iter = min(i, final_iter);
        disp(['Final iteration =',num2str(i)])

        disp(' Q State vs Actions')

        Q_State_Action

        disp('  State Value')

       
        if(Plot_Flag && (k < 3 || k == N_glob_epoch))
            Plot_State_Value (State_Value, final_iter, ['_',num2str(k),'_'])
        end
        
        Global_Q_State_Action(:,:,k) = Q_State_Action;
        Global_State_Value(:,:,k) = State_Value;
        
    end %Glob Epochs
    
 
    format shortg
    c=clock;
    time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];
    
    if ~exist('./Output/Current/backup', 'dir')
       mkdir('./Output/Current/backup')
    end

    filename = ['./Output/Current/backup/workspace_CurrentSS_', time_string, '.mat'];
    save(filename, 'State_Value', 'N_State_Action_p',  'Q_State_Action')
    filename = ['./Output/Current/backup/Global_Values_SS_', time_string, '.mat'];
    save(filename, 'Global_Q_State_Action', 'Global_State_Value')

    if Plot_Flag
        Plot_Figures(final_iter, Final_time_index, Final_reward, reward_mat, Pain_mat, State_time_mat);
        Plot_Sample_Figures(final_iter, State_time_mat, reward_mat, Pain_mat, this_reward_mat, working_mode_mat);
    end  

end


function  conv_condition = Check_Convergence(Check_Span, State_Value, N_trials, i)
    
    % verify if at least the 70% of the episodes has been carried on 
    % and the variance is limited in the last Check_Span items
    Plot_flag =0;   
    conv_condition=0;
    if( i > Check_Span )
        if  (i  > 0.7 * N_trials)
            State_Value_Stat = State_Value(i-Check_Span:i,:);
            if(max(var(State_Value_Stat))< 0.005)
                  conv_condition=1

                  if(Plot_flag)
                    Plot_State_Value (State_Value, i, 'conv') 
                  end
           end
       end
    end
end

function New_State = Pain_State( Pain, time_index, global_time)

    
    P  = Pain(global_time);
    
    if( P > 0.8)
        New_State=3;
    elseif (P > 0.3)   
       New_State=2;
    else
       New_State=1;
     end
    
end


function  [reward, this_reward, E] = Calculate_Reward_State_Action_with_Pain(State, this_Cluster, Action_Reward, Pain,  time_index, N_action_in_a_seq, cluster_vs_time, N_Clusters)

    this_reward = Action_Reward (this_Cluster) ; %%instant reward
    
    this_pain = Pain( (time_index-1) * N_action_in_a_seq);
   
    E = Eval_entropy(cluster_vs_time, N_Clusters);
 
    reward =  (this_reward - this_pain);

end


function    E = Eval_entropy(action_time, N_Actions)

    
    P_a = zeros(1,N_Actions);
    
    for i=1:N_Actions
        
        P_a(i)=  size(find(action_time==i),2);
        
    end
    
    P_a = P_a./sum(P_a');
    E = 0;
    
    for i=1:N_Actions
       
        if(P_a(i)>0)
            E = E - P_a(i)*log(P_a(i));
        end
        
    end

    
end


 function action = Choose_Action_Greedy(Q_State_Action, State, epsilon, N_Actions)


        r = rand();
        action_rewards = Q_State_Action(State,:);

        if(r < epsilon || abs(max(action_rewards)-min(action_rewards)) <1e-2 )
            %casually choose an action
            action = randi([1, N_Actions]) ; 
        else

            [max_v, action]= max(action_rewards);
        end



    end


 function Plot_Action_Cost(Action_Reward, Action_Cost, N_Actions, n_steps)
      
        for j=1 : N_Actions

            figure(j);
            clf
            hold on
            subplot(2,1,1)                  % add first plot in 2 x 2 grid
            plot((1:n_steps),Action_Reward(j,:))           % line plot
            ylim([0 1.2]);
            title('Reward vs time')

            subplot(2,1,2)                  % add second plot in 2 x 2 grid

            plot((1:n_steps),Action_Cost(j)*ones(1,n_steps)  )         % line plot
               ylim([-0.5 2.5]);
            title('Cost vs time')

            print(['Action_',num2str(j)],'-dpng')


        end
 end
 
     
 function New_Cluster = State_Transition(Transition_Matrix, Current_Cluster, mode)

    this_Cluster_Transition_v = Transition_Matrix(Current_Cluster, : ,mode);

    New_Cluster = 1;
    cumulative_p = this_Cluster_Transition_v(New_Cluster);
    r = rand();
    
    while ( r > cumulative_p)
        
        New_Cluster = New_Cluster+1;
        if(New_Cluster >  size(this_Cluster_Transition_v, 2))
            keyboard
        end
            
        cumulative_p = cumulative_p + this_Cluster_Transition_v(New_Cluster);
    end
    
end

function Transition_Matrix = Load_Current_Transition_Matrix(N_Clusters, Cluster_Curr, file_name )

    show_fig=0;
    Transition_Matrix = [];
    
   
    if exist(file_name, 'file') == 2
   
        my_data = csvread(file_name);
        
        [nr ncc] = size(my_data);
        
        if(nr ~= N_Clusters)
           disp ('Error in N_Clusters')
           keyboard
        end
        
        Transition_Matrix=zeros(N_Clusters, N_Clusters,  ncc /nr);
        
        for i =1 : ncc /nr 
            
            Transition_Matrix(:,:,i) = my_data(1:nr,  N_Clusters*(i-1)+1 : N_Clusters*i);
            Transition_Matrix(:,:,i) = Normalize_Mat_rows(Transition_Matrix(:,:,i));
        end
        
        Total_Curr_Cluster = sum(Cluster_Curr);
        
        alpha = 0.05;
        beta = 5*alpha;
        indx =1;
       
        N_samples = 20;
        Pain = zeros(1, N_samples);
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
        %file does not exist
        disp(['Error: I cannot find ', file_name])
        
    end
    
    if(isempty(Transition_Matrix)==1)
        disp ('Transition Matrix is set randomly')
        Transition_Matrix = rand(N_Clusters,N_Clusters,3)
       % Transition_Matrix = Set_Transition_Matrix(N_Clusters, Cluster_Curr);
    end

    if(check_TM(Transition_Matrix)==0)
        disp ('Error in Transition Matrix')
    end
end


function out = check_TM(Transition_Matrix)

    out=1;
    
    [nr, nc, nd]=size(Transition_Matrix);
    
    s1= sum(sum(Transition_Matrix(:,:,1)'));
    s2= sum(sum(Transition_Matrix(:,:,2))');
    s3= sum(sum(Transition_Matrix(:,:,3))');
    
    test_1 = ( abs(s1-nr) > 10*eps * max( abs(s1), nr));
    test_2 = ( abs(s2-nr) > 10*eps * max( abs(s2), nr));
    test_3 = ( abs(s3-nr) > 10*eps * max( abs(s3), nr));
    
    if(test_1 || test_2 || test_3) 
        out=0;
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


function New_Cluster_Curr =  Sort_Cluster_Curr(Cluster_Curr)


    Curr_Sum = sum (Cluster_Curr);

    [v, indx] = sort(Curr_Sum);
    
    
    for i = 1: size(Cluster_Curr,2)
       
        New_Cluster_Curr(:,size(Cluster_Curr,2)-i+1) = Cluster_Curr(:, indx(i));
        
    end


end


function Cluster_Curr = Set_Cluster_Curr(NC)

    Load_Current_Cluster = true
    
    if(Load_Current_Cluster)
        
        Cluster_Curr = csvread('./res/Current/Current_Cluster.csv');
        
    else
    
       Cluster_Curr = rand(10,20);

    end

end
 
function  Reward = Load_Reward_Matrix(N_Clusters, Reward_fname)

    show_fig=0;
    Transition_Matrix = [];

    if exist(Reward_fname, 'file') == 2
                
        Reward = csvread(Reward_fname);

    end
    
end


function New_Cluster = Cluster_Transition(Transition_Matrix, Current_Cluster, mode)

    this_Cluster_Transition_v = Transition_Matrix(Current_Cluster, : ,mode);

    New_Cluster = 1;
    cumulative_p = this_Cluster_Transition_v(New_Cluster);
    r = rand();
    
    while ( r > cumulative_p)
        
        New_Cluster = New_Cluster+1;
        if(New_Cluster >  size(this_Cluster_Transition_v, 2))
            keyboard
        end
            
        cumulative_p = cumulative_p + this_Cluster_Transition_v(New_Cluster);
    end
    
end
function reward = Check_Pain_Threshold( Pain_mat, i , time_index, reward)
    
    if(time_index >10)
        if( mean( Pain_mat(i,time_index-10: time_index))> 0.98)
            reward =-100;
        end
    end

end
                
               

   
 