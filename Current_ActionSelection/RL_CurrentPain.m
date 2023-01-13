function RL_CurrentPain(current_dir)


% Optimize according three thresholds

    %the process of discharge of the battery is simulated with the discharge of
    %a capacitor
    %these values are given by the problem, differen robots can have different
    %values

    %tau_0 is the time constant for the discharge (esponential) in normal mode.
    %It is supposed that the charge becomes an half of the initial (full)
    %value in one hour.
    %
    % tau_0 =3600/log(0.5)% NORMAL Mode it is supposed to reach half of the charge in one hours
    % tau_1 =(3600*2)/log(0.5) %HUNGRY it is supposed to reach half of the charge in two hours
    % tau_2 =(3600*4)/log(0.5) %STARVED it is supposed to reach half of the charge in four hours
    % tau_3 =(3600*8)/log(0.5) %STOP it is supposed to reach half of the charge in eight hours
    %older versione: time has been limited to make the simultion easier

    %8 marzo we consider a policy to choose the best action, meaning 
    % 3 aug cambiato il valore di alpha nell'implementazione sarsa

    %addpath('./libs/','-end')
    %addpath('./Somatosensory/','-end')
    
    N_Actions = 3; %Three possible modes for transition probability

    time_max    = 14400
    Max_Value   =1
    n_steps     =120%time steps 
    N_action_in_a_seq = 10;
   
    Pain_threshold = 0.5
    N_trials = 1000;

    Plot_Flag = true
    
    % Setting the thresholds

    th=[75, 50, 30, 25];

    
    threshold_recharge = 98;
    %threshold_recharge = 100
    % Setting the time constants


    % tau_0 =600/log(0.5)% NORMAL Mode it is supposed to reach half of the charge in 10 mins
    % tau_1 =(3600*2)/log(0.5) %HUNGRY it is supposed to reach half of the charge in 20 mins
    % tau_2 =(3600*4)/log(0.5) %STARVED it is supposed to reach half of the charge in 40 mins
    % tau_3 =(3600*8)/log(0.5) %STOP it is supposed to reach half of the charge in 80 mins

    %Tau =[-30, -28, -26, -24, 0.5, 1, 2, 4, 8, 10, 11, 12];
        
    %indx_neg = find(Tau < 0);
    %indx_pos = find(Tau >= 0);
    %4, 8, -20, 3, 9, -18, 4, 8, -27, 3, 9 ]
    %Tau = 600 * Tau /log(0.5);
    
    Tau_Charge      =   (3600*2/100)/log(0.5); % it is supposed to reach half of the charge in 0.2 mins
    Tau_Discharge   =   (3600*2/10)/log(0.5);
    time_v =  linspace(1, time_max, n_steps * N_action_in_a_seq);

    %N_trends = size(Tau,2);
 
    show_all_figures=0

    % Load Transition Matrix
    
    N_Clusters = 20; %max value is 20
    
    Cluster_Curr =  Set_Cluster_Curr(N_Clusters); %caricare da file
    
    %Transition_Matrix = Load_Current_Transition_Matrix(N_Clusters, Cluster_Curr, './data/TrMat.csv');
    Transition_Matrix = Load_Current_Transition_Matrix(N_Clusters, Cluster_Curr, './res/Current/TrMat.csv');
    
    if(isempty(Transition_Matrix)==1)
        disp ('Error in Loading Transition Matrix')
        %keyboard
        Transition_Matrix = Set_Transition_Matrix(N_Clusters, Cluster_Curr);
    end
    
    if(check_TM(Transition_Matrix)==0)
        disp ('Error in Transition Matrix')
        keyboard
    end
    
    plot_reward = 0;
    
    if(plot_reward)
        Plot_Figures(Action_Reward, Action_Cost, N_Actions, n_steps)
    end
    
    Global_Q_State_Action=[]
    Global_State_Value=[]
    %N_glob_epoch = 1000;
    N_glob_epoch = 5;
    N_States = 3; % Three possible modality corresponding to the three transition matrices
    Reward      = Load_Reward_Matrix(N_Clusters, './res/Current/Reward.csv');
    Q_State_Action  = zeros(N_States, N_Actions); %Action is the choice among the three modes (three transition matrices)
    N_State_Action  = zeros(N_States, N_Actions);
      
    
    for k = 1 : N_glob_epoch
      
        %Reward      = Load_Reward_Matrix(N_Clusters, './res/Current/Reward.csv');
        Pain        = zeros(N_trials, n_steps * N_action_in_a_seq);
        Current     = zeros(N_trials, n_steps * N_action_in_a_seq);
        
        %State_Value     = zeros(1,N_States);
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

        index =1;
        State_Value         = zeros(N_trials, N_States);
        conv_condition = 0
       
        final_iter = N_trials; 
        %max_iter=1; 
        i=1;
        while (i <= N_trials  && conv_condition==0)

            disp(['Episode ',num2str(i)]);
            Charge = 100; %around 1.0 average cost for 100 steps
            Pain = 0;

            State=1; %NORMAL 
            time_index = 1 ;

            %working_mode_mat(i, time_index)  = floor(rand(1,1)*3)+1; % begins from nay transition mat
            working_mode_mat(i, time_index)  = 1; % begins from nay transition mat
            State_time_mat(i, time_index) = State;  %stato del dolore
            Value_time(time_index) = 0;

            action = Choose_Action_Greedy(Q_State_Action, State, epsilon_trials(i), N_Actions);

            %cluster_vs_time(time_index)=action;
            cluster_vs_time(time_index) = 1; %always starts from first cluster
            Pain(1)=0;
            Current(1)=1;

            for j = 2 : N_action_in_a_seq

                indx =  j;
                Current(indx) = Cluster_Curr (j, Current_Cluster(1)) ; 

                
                Pain(indx) = CurrentPain_Somatosensory(Current(indx), Pain_threshold,  Pain(indx-1), Max_Value, time_v(indx), time_v(indx-1), Tau_Charge, Tau_Discharge);
                
%                 if ( Current(indx) > Pain_threshold )
%                     %raise the pain perception
%                     Pain(indx) = Pain(indx-1) + (Max_Value - Pain(indx-1)) * (1 - exp((time_v(indx) - time_v(indx-1))/ Tau_Charge));
%                 else
%                     %reduce the pain perception
%                     Pain(indx) =Pain(indx-1) *( 1- exp((time_v(indx) - time_v(indx-1))/ Tau_Discharge));
%                 end
            end

            time_index=2;
            reward =0;
            % per ogni transizione si riduce la carica di Action_Cost(j) 
            while time_index <= n_steps && reward > -100

                 %to evaluate state value
                N_State_Action(State, action)= N_State_Action(State, action) + 1 ;

                %repeat from state Normal to the state Stop
                %reward = Calculate_Reward_State_Action(State, action, Action_Reward, time_index, action_time, N_Actions);

                [reward, this_reward_mat(i, time_index), Entropy_mat(i,time_index)] = Calculate_Reward_State_Action_with_Pain(State, Current_Cluster(time_index-1), Reward, Pain, time_index, N_action_in_a_seq,  cluster_vs_time, N_Clusters);

                reward_mat(i, time_index) = reward;
                % new action : according the current pain state and transition matrix get the new cluster

                Current_Cluster(time_index) = Cluster_Transition(Transition_Matrix, Current_Cluster(time_index-1),  working_mode_mat(i, time_index-1) );

               % [New_State, Charge] = State_Transition(Charge, State, action, Threshold_Vect, Action_Cost);
                dbg_indx = 0;
                dbg_custers=0;

               %Calculte Pain
                for j = 1 : N_action_in_a_seq

                    indx = (time_index-1) * N_action_in_a_seq + j;
                    Current(indx) = Cluster_Curr (j, Current_Cluster(time_index)) ;
                    if(dbg_indx==1)
                            disp(['dbg_indx) indx = ',num2str(indx)])
                    end

                    if ( Current(indx) > Pain_threshold )
                         %raise the pain perception
                         Pain(indx) = Pain(indx-1) + (Max_Value - Pain(indx-1)) * (1 - exp((time_v(indx) - time_v(indx-1))/ Tau_Charge));
                    else
                         %reduce the pain perception
                         Pain(indx) = Pain(indx-1)* ( exp((time_v(indx) - time_v(indx-1))/ Tau_Discharge));
                    end
                end

                Pain_mat(i, time_index) = Pain(indx);
                if(time_index >10)
                    if( time_index >10 && mean( Pain_mat(i,time_index-10: time_index))> 0.98)
                        reward =-100;
                    end
                end

                New_State = Pain_State( Pain, time_index, indx);
                    %%according the current pain state and Q matrix choose the
                    %%new action
                %action corresponds to the work modality, implemented through
                %the transition matrices
                new_action = Choose_Action_Greedy(Q_State_Action, New_State, epsilon_trials(i), N_Actions);

                working_mode_mat(i, time_index) = new_action; 

                Q_State_Action (State, action) = Q_State_Action(State, action) + (reward + gamma * Q_State_Action(New_State, new_action)-  Q_State_Action (State, action))/i; %alpha has been changed bt 1/t for robbins monro sequence

                %Update
                State = New_State;
                action = new_action;

                %Reward_time(time_index)= reward;

                State_time_mat  (i, time_index)= State;
                cluster_vs_time (time_index)=  Current_Cluster(time_index);

                if(time_index>1)
                    Value_time(time_index) = Value_time(time_index-1)+ reward;
                else
                    Value_time(1) =  reward;
                end

                time_index = time_index+1;

               % if(dbg_custers==1)
                %   disp('dbg_clusters')
               %    cluster_vs_time
               % end
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
        %max_iter = max(i, max_iter)
        disp(['Final iteration =',num2str(i)])

       

      
            %N_State_Action = normr(N_State_Action)

        %%%%
        %c=clock
        %time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];

        %filename = ['./backup_Current/WS_Current_SS_', time_string, '.mat'];
        %save(filename)

        %%%%%

        disp(' Q State vs Actions')

        Q_State_Action

        disp('  State Value')

        %State_Value_Stat = State_Value(final_iter-10:final_iter,:)
        %State_Value
        if(Plot_Flag && k < 3)
            
            Plot_State_Value (State_Value, final_iter, ['_',num2str(k),'_'])
%             figure(11)
%             clf
%             plot(State_Value(1:final_iter,:))
%             legend('State 1', 'State 2', 'State 3');
%             title('State Value');
%             print(['./Output/Current/State_Value_',num2str(final_iter)],'-dpng')
        end
        
        Global_Q_State_Action(:,:,k) = Q_State_Action;
        Global_State_Value(:,:,k) = State_Value;
        
    end %Glob Epochs
    
 
    format shortg
    c=clock;
    %time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
    time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];
    
    if ~exist('./Output/Current/backup', 'dir')
       mkdir('./Output/Current/backup')
    end

    filename = ['./Output/Current/backup/workspace_CurrentSS_', time_string, '.mat'];
    %save(filename)
    save(filename, 'State_Value', 'N_State_Action_p',  'Q_State_Action')
    %        'Reward_State_Action', 'Q_State_Action', 'state_names',)
    %keyboard
    filename = ['./Output/Current/backup/Global_Values_SS_', time_string, '.mat'];
    save(filename, 'Global_Q_State_Action', 'Global_State_Value')

    if Plot_Flag
        %Plot_figures(final_iter, Final_time_index);
        Plot_Figures(final_iter, Final_time_index, Final_reward, reward_mat, Pain_mat, State_time_mat);
        Plot_Sample_Figures(final_iter, State_time_mat, reward_mat, Pain_mat, this_reward_mat, working_mode_mat);
    end %Plot Flag 


    %keyboard
    
    %disp("Median")
    %median(Global_Q_State_Action,3)
    %median(Global_State_Value,3)
    
    %v11=sqrt(var( Global_Q_State_Action(1,3,:)))
    %keyboard
    %disp("variance")
    %var(Global_Q_State_Action,3)
    %var(Global_State_Value,3)


end


function  conv_condition = Check_Convergence(Check_Span, State_Value, N_trials, i)
    
    % verify if almost the 70% of the episode has been 
    % verify if in the last Check_Span items the variance is limited (converged)
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

% function Plot_State_Value (State_Value, i, tag)
% 
%     figure(11)
%     clf
%     plot(State_Value(1:i,:), 'LineWidth', 3, 'LineStyle', '-')
% 
%     % title('State Value');
%     lgd = legend({'Normal', 'Tired', 'Aching'}, 'Location','southeast');
%     lgd.FontSize = 16;
%     ylim([-10 3])
%     xlim([0 200])
%     xlabel('training iter','FontSize',16','FontWeight','bold');
%     ylabel('Value','FontSize',16,'FontWeight','bold')
%     %print(['./imgs/State_Value',num2str(i)],'-dpng')
%     print(['../Output/Current/State_Value_',num2str(i),tag],'-dpng')
% 
% end

function New_State = Pain_State( Pain, time_index, global_time)

    
    P  =Pain(global_time);
    
    if( P >0.8)
        New_State=3;
    elseif  (P >0.3)   
       New_State=2;
    else
       New_State=1;
     end
    
end


function  [reward, this_reward, E] = Calculate_Reward_State_Action_with_Pain(State, this_Cluster, Action_Reward, Pain,  time_index, N_action_in_a_seq, cluster_vs_time, N_Clusters)
%State, action, Reward, Pain, time_index, action_time, N_Actions);
   dbg = 0;
   this_reward = Action_Reward (this_Cluster) ; %%instant reward
    
    %this_reward= 0.0; %%FOR DEBUG
    
    this_pain = Pain( (time_index-1) * N_action_in_a_seq);
    %calculate Pain

    E = Eval_entropy(cluster_vs_time, N_Clusters);

    if(dbg==1)
        disp('dbg Calculate_Reward_State_Action')
        this_reward
        Pain(time_index)
    end
    
    %reward =  0.7*(this_reward - Pain(time_index))+0.3 *E;
    reward =  (this_reward - this_pain);

end


  
% function  [reward, this_reward, E] = Calculate_Reward_State_Action(State, action, Action_Reward, time_index, cluster_vs_time, N_Actions)
% 
%    dbg =0;
%     global_time =  size(action_time,2);
% 
%     action_time = action_time(1, global_time - time_index+1 : global_time); 
% 
%     %current reward 
%     if(dbg==1)
%         disp('dbg Calculate_Reward_State_Action')
%         
%         action_time
%     end
%     this_reward = Action_Reward(action, time_index ) ;
% 
%     
%     E = Eval_entropy(action_time, N_Actions);
%     
%      if(dbg==1)
%     disp(['reward = ',num2str(reward), ' Entropy = ', num2str(E)]);
%         
%        
%      end
%     
%     
%     reward = 0.9 * this_reward +0.1 * E;
% 
% 
% 
% 
% end


function    E = Eval_entropy(action_time, N_Actions)

    
    P_a = zeros(1,N_Actions);
    
    for i=1:N_Actions
       
        %n =  min( size(find(action_time==i)));
        
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
            action = randi([1, N_Actions]) ; % 4 is N_actions
        else

            [max_v, action]= max(action_rewards);
        end



    end


   % function New_State = State_Transition(Transition_Matrix, State, action)
%     function [New_State, Charge] = State_Transition(Charge, State, action, Threshold_Vect,  Action_Cost)
% 
%         i=1;
%         
%         Charge = Charge - Action_Cost(action);
%        
%         if Charge < 0 
%             
%             New_State = size(Threshold_Vect,2);
%         else
%             
%             while Charge < Threshold_Vect(i) && i < 5
% 
%                 i=i+1;
%                 if(Charge < 0)
%                     i = size(Threshold_Vect,2)
%                     keyboard
%                 end
% 
%             end 
% 
%             New_State=i;
% 
%         end
%     end

    %fun that Set the state according the value of the variable value

%     function S =  Set_State(state, value, threshold_vect, threshold_recharge)
%     % this function is alternative to the transition matrix
%     dbg = 0
% 
%     %state 4 is recharge
% 
%         if(state ~= 4)
%             ps = find(threshold_vect <= value)
% 
%             if dbg 
%                 if isempty(ps)
%                     keyboard
%                 else
%                     S = min(ps)
%                     if S == 4
%                        S
%                     end
%                 end
%             end
%             S = min(ps)
%         else
%             %recharging
%             if value >= threshold_recharge
%                 S = 1;
%                 disp('recharge completed')
%             else
%                 S = 4;
% 
%             end
%         end
%     end


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
    
    %if exist('./data/TrMat.csv', 'file') == 2
    if exist(file_name, 'file') == 2
        %my_data = matfile('TrMat.mat')
        %Transition_Matrix = my_data.Transition_Matrix;
        my_data = csvread(file_name);
        
        [nr ncc] = size(my_data);
        
        if(nr ~= N_Clusters)
           disp ('Error in N_Clusters')
           keyboard
        end
        
        Transition_Matrix=zeros(N_Clusters, N_Clusters,  ncc /nr);
        
        for i =1 : ncc /nr 
            
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
        
    end
end


function out = check_TM(Transition_Matrix)

    out=1;
    
    [nr, nc]=size(Transition_Matrix);
    
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
    
        Cluster_Curr =[
                0.03408,0.15016,0.06378,0.0339,0.18882,1,0.037745937,0.956035768,0.01072353,0.740166261,0.12944,0.02151,0.1751,0.08292,0.09704,0.00016,0.02886,0.00495,0.22017,0.07076;
        0.06141,0.16142,0.02444,0.05244,0.02679,0.815274218,0.003849444,0.54258037,0.075434488,0.119829684,0.05236,0.17733,0.30055,0.04512,0.05592,0.07066,0.02718,0.28575,0.17997,0.12636;
        0.04404,0.1181,0.0931,0.0449,0.10719,0.471963096,1,0.715669576,0.989399729,0.704176805,0.13458,0.14541,0.13665,0.0414,0.01422,0.02734,0.1061,0.0084,0.11826,0.15152;
        0.06714,0.0359,0.01226,0.05144,0.11997,0.250538186,0.965034217,0.887907175,0.087760385,0.338300892,0.05752,0.18828,0.36875,0.14928,0.05532,0.17356,0.10778,0.1485,0.11355,0.2124;
        0.04614,0.02188,0.09006,0.03012,0.05091,0.043362378,0.713002566,0.231317862,1,0.907745337,0.14596,0.13386,0.1512,0.15111,0.09284,0.1927,0.12532,0.18243,0.20868,0.29552;
        0.08076,0.07296,0.05492,0.1201,0.03963,0.52639672,0.265718563,0.302107728,0.3079009,0.152473642,0.1519,0.00399,0.22855,0.08964,0.00872,0.0414,0.0924,0.00465,0.21411,0.23496;
        0.10419,0.04168,0.06795,0.06254,0.28458,0.821629933,0.768284859,0.407813498,0.12769629,1,0.04706,0.08559,0.1538,0.2883,0.09312,0.07726,0.18086,0.012,0.26484,0.25272;
        0.0546,0.09244,0.07828,0.09276,0.2745,0.138698104,0.314478186,1,0.942561321,0.579480941,0.16114,0.20379,0.26265,0.19257,0.13378,0.18944,0.05742,0.1614,0.05229,0.10696;
        0.04161,0.15264,0.07489,0.15042,0.12114,0.636289083,0.261976048,0.978284011,0.886971527,0.027169505,0.13778,0.17685,0.45205,0.12807,0.08362,0.14468,0.12566,0.21924,0.13041,0.01196;
        0.08025,0.0134,0.09244,0.07072,0.1485,0.155509995,0.305175364,0.897168405,0.365709355,0.193227899,0.0937,0.09975,0.3802,0.12102,0.02716,0.17454,0.15936,0.29967,0.0864,0.2266;

        ];


        Cluster_Curr =  Cluster_Curr(:,1:NC);
        if(NC < 5)
            keyboard
        end

           Cluster_Curr(:,1) = ones(1,10);
           Cluster_Curr(:,2) = 0.9 * ones(1,10);
          % Cluster_Curr(:,8) = 0.9* ones(1,10)
          % Cluster_Curr(:,7) = 0.9 * ones(1,10)


           Cluster_Curr =  Sort_Cluster_Curr(Cluster_Curr);

            Cluster_Curr(:,5) = 0.5 * Cluster_Curr(:,5) ;
            Cluster_Curr(:,6) = 0.5 * Cluster_Curr(:,6) ;

            Cluster_Curr =  Sort_Cluster_Curr(Cluster_Curr);

            csvwrite('./res/Current/Current_Cluster.csv', Cluster_Curr);
    end

end
 
function  Reward = Load_Reward_Matrix(N_Clusters, Reward_fname)

    show_fig=0;
    Transition_Matrix = [];
    %'../res/Current/Reward.csv'
    if exist(Reward_fname, 'file') == 2
                
        Reward = csvread(Reward_fname);

    end
    
end

%function New_Cluster = Action_Transition(Transition_Matrix, Current_Cluster, mode)
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
   
 