

%
% Experiment for the selection of energy modes according to the Energy Roboception

% The experiment is described in Section "Behavior Mode Selection through Reinforcement Learning" 

% of the paper 

% "Roboception and adaptation in a cognitive robot"

% by 

% Agnese Augello,Salvatore Gaglio,Ignazio Infantino,Umberto Maniscalco,Giovanni Pilato,Filippo Vella



%function ReinforcementLearning_GreedPolicy

function main

    %time_max    = 14400 ;  to be erased
    
    addpath('../libs/','-end')
    %addpath('/Users/filippo/Workshop/Cold_Projects/Robotics/Somatosensory_System/Code_Repo_1/libs/','-end')

    Max_Value   = 100;
    n_step      = 100;

    % Setting the thresholds

    % th=[75, 50, 30, 25]; to be erased

    threshold_recharge = 98;

    %threshold_recharge = 100
    % Setting the time constants

    %tau_0 =600/log(0.5);% NORMAL Mode it is supposed to reach half of the charge in 10 mins
    %tau_1 =(3600*2)/log(0.5); %HUNGRY it is supposed to reach half of the charge in 20 mins
    %tau_2 =(3600*4)/log(0.5); %STARVED it is supposed to reach half of the charge in 40 mins
    %tau_3 =(3600*8)/log(0.5); %STOP it is supposed to reach half of the charge in 80 mins

    state_names     =   ["Normal"; "Hungry"; "Starved";  "Out of Charge" ];

    action_names    =   ["Full"; "Economy"; "Recharge" ];

    N_States = size(state_names,1);

    N_Actions = size(action_names,1);

    % Reward_State_Action=[   100,    50,         -10;
    %                        50,     100,        -8;
    %                       5,     80,          -4;
    %                       -100,   -100,       -100];

    %from poisson
    %lambda_vect = [3,5,7]
    %sample_index =[2,4,8];
    
    
    %keyboard
    %N_states, N_actions, file_name
    Reward_State_Action = Load_Energy_Reward_Matrix(N_States, N_Actions, '../res/Energy/Reward_StateAction_Energy.csv');
  
       if(false)
        Reward_State_Action=[   224,    168,         8;
                                82,     175,        65;
                               22,     91,          130;
                                -100,   -100,       -100];

        Reward_State_Action = Reward_State_Action - 100*ones(4,3)
       end

    if(false)
    %transition matrix for action Full (work)

        Transition_Matrix(:,:,1)=[
            0.4, 0.5,   0.1,     0;
            0,  0.4,    0.5,     0.1;
            0,  0,      0.4,     0.6;
            0,  0,      0,       1];

        %transition matrix for action Economy (work)

        Transition_Matrix(:,:,2)=[
            0.5, 0.4,   0.1,     0;
            0,  0.5,    0.4,     0.1;
            0,  0,      0.7,     0.3;
            0,  0,      0,       1];


        %transition matrix for action Recharge

        Transition_Matrix(:,:,3)=[
            1,0,0,0;
            1,0,0,0;
            1,0,0,0;
            0,0,0,1;
        ];


        %transition matrix for action STOP

        Transition_Matrix(:,:,4)=[
            0.97,   0.02,    0.01,          0;
            0.0,      0.95,   0.04,         0.01;
            0.0,      0.0,      0.9,       0.1;
            0.0,      0.0,      0.0,        1];
    end

    Transition_Matrix = Load_Transition_Matrix(N_States, N_States, '../res/Energy/Transition_Matrix_Energy.csv')
    
    Q_State_Action = zeros(N_States, N_Actions);


    N_State_Action= zeros(N_States, N_Actions);
    State_Value  = zeros(1,N_States);

    %RL Params
    alpha = 0.5;
    epsilon = 0.2;
    gamma = 0.7;


    Global_Q_State_Action=[];
    Global_State_Value=[];
    %N_glob_epoch = 1000
    N_glob_epoch = 5

    for k=1:N_glob_epoch

        N_trials = 10000;
        disp(['Epoch = ', num2str(k)])

        State = 1;
        N_samples = N_trials * 10;
        State_time = zeros(1,N_samples);
        Reward_time= zeros(1,N_samples);
        Value_time = zeros(1,N_samples);
        Action_time= zeros(1,N_samples);
        index = 1;

        final_state = find(strcmp( "Out of Charge",state_names) );

        for i = 1 : N_trials

            State = 1; %init at state 1
            State_time(index)= State;  
            Value_time(index) = 0;
            action = Choose_Action_Greedy(Q_State_Action, State, epsilon, N_Actions);
            action_time(index)=action;

            while State ~= final_state % Out_of_charge

                %increase state action statistics
                N_State_Action(State, action)= N_State_Action(State, action) +1 ;

                %repeat from state Normal to the state Stop
                reward = Reward_State_Action(State, action);

                New_State = State_Transition(Transition_Matrix, State, action);

                if(New_State == final_state)
                  reward = min(min(Reward_State_Action));
                end

                new_action = Choose_Action_Greedy(Q_State_Action, New_State, epsilon, N_Actions);

                Q_State_Action (State, action) = Q_State_Action(State, action) + alpha*(reward + gamma * (Q_State_Action(New_State, new_action) -  Q_State_Action (State, action)));

                State = New_State;
                action = new_action;

                %update values
                Reward_time(index)= reward;
                index = index+1;
                State_time(index)= State;
                action_time(index)= action;
                Value_time(index) = Value_time(index-1)+ reward;
            end

            Reward_time(index)= reward;
            index = index+1;

        end

       %normalize according the number of chosen actions
       N_State_Action_p =  bsxfun(@times, N_State_Action, 1./(sum(N_State_Action, 2)));

        for i= 1:N_States

            for j =1:N_Actions

                State_Value(i) = State_Value(i) +  N_State_Action_p(i,j)* Q_State_Action(i,j);
            end

        end



        Global_Q_State_Action(:,:,k)=Q_State_Action;
        Global_State_Value(:,:,k) = State_Value;
    end

        c=clock
        %time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
        time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];

        disp('Reward State Actions')
        Reward_State_Action
        disp(' Q State vs Actions')

        Q_State_Action
        state_names  
        
        disp('  State Value')
        State_Value

        filename = ['../res/Log/Energy/WS_Energy_SS_', time_string, '.mat'];
        save(filename,'Reward_State_Action', 'Q_State_Action', 'state_names', 'State_Value') 
      
        if(false)
            disp("Median Q_State_Action")
            median(Global_Q_State_Action,3)

            disp("Median State_Value")
            median(Global_State_Value,3)
        end
        
        disp("Average Q_State_Action")
        Mean_Q = mean(Global_Q_State_Action,3)
        disp("Average State_Value")
        Mean_State_Value = mean(Global_State_Value,3)
        
        disp("variance Q_State_Action")
        Var_Q_State_Action = Evaluate_Variance__t(Global_Q_State_Action,3)
       
        disp("variance State_Value")
        Var_State_Value  = Evaluate_Variance__t(Global_State_Value,3)

        
        Plot_State_Value(Global_State_Value, state_names, 1, '../Output/Energy/State_values_Energy_Modes')
       
      
        
        Plot_3d_State_Action(Mean_Q, Var_Q_State_Action, 2, state_names,action_names,  '../Output/Energy/Q_State_Action_')
        
       
        

end



function action = Choose_Action_Greedy(Q_State_Action, State, epsilon, N_Actions)
    
    r = rand();
    action_rewards = Q_State_Action(State,:);
    
    if(r < epsilon || (max(action_rewards)==min(action_rewards)))
        %casually choose an action
        action = randi([1, N_Actions]) ; % 4 is N_actions
    else
        
        [max_v, action]= max(action_rewards);
    end
    


end


function New_State = State_Transition(Transition_Matrix, State, action)

    this_State_Transition_v = Transition_Matrix(State,:,action);

    New_State = 1;
    cumulative_p = this_State_Transition_v(New_State);
    r = rand();
    
    while ( r > cumulative_p)
        
        New_State = New_State+1;
        cumulative_p = cumulative_p + this_State_Transition_v(New_State);
    end
    
end

%fun Set_State modify the state according to the variable value

function S = Set_State(state, value, threshold_vect, threshold_recharge)
% this function is alternative to the transition matrix
dbg = 0

%state 4 is recharge

    if(state ~= 4)
        ps = find(threshold_vect <= value)

        if dbg 
            if isempty(ps)
                keyboard
            else
                S = min(ps)
                if S == 4
                   S
                end
            end
        end
        S = min(ps)
    else
        %recharging
        if value >= threshold_recharge
            S = 1;
            disp('recharge completed')
        else
            S = 4;

        end
    end
end
 


function S =  Set_State_only_threshold(value, threshold_vect)

    dbg = 0
    ps = find(threshold_vect <= value)

    if dbg 
        if isempty(ps)
            keyboard
        else
            S = min(ps)
            if S == 4
               S
            end
        end
    end
    S = min(ps) 

end

function M = Normalize_Rows(Mat)

    SR = sum(Mat');

    for i = 1: size(Mat,1)
       M(i,:) = Mat(i,:)/SR(i) 

    end


end
