% RL_EnergyModes_URGE

% Experiment for the selection of energy modes according to the Energy Roboception

% The experiment is described in "Behavior Mode Selection through Reinforcement Learning" 

% by 

% Agnese Augello, Salvatore Gaglio, Ignazio Infantino, Umberto Maniscalco, Giovanni Pilato, Filippo Vella



function RL_EnergyModes_URGE(current_dir)



    Max_Value   =100;
    n_step      =100;
    %value of the thresholds

    th_1  = 75;
    th_2  = 50;
    th_3  = 25;

    % Setting the thresholds

    th=[75, 50, 30, 25];

      addpath('./libs/','-end')
        addpath('./Somatosensory/','-end')

    threshold_recharge = 98;

    state_names     =   ["Normal"; "Hungry"; "Starved";  "Out_of_Charge" ];
    action_names    =   ["Full"; "Economy"; "Recharge" ];

    N_States = size(state_names,1);
    N_Actions = size(action_names,1);


    Reward_State_Action = Load_Energy_Reward_Matrix(N_States, N_Actions, './res/Energy/Reward_StateAction_Energy_URGE.csv');


    Transition_Matrix = Load_Transition_Matrix(N_States, N_States, './res/Energy/Transition_Matrix_Energy_URGE.csv');


    Q_State_Action = zeros(N_States, N_Actions);
    N_State_Action= zeros(N_States, N_Actions);
    State_Value  = zeros(1,N_States);


    alpha = 0.5;
    epsilon =0.2;
    gamma = 0.7;
    verbose_flag = false;
    State = 1;

    N_glob_epoch = 1000
    N_glob_epoch = 5

    Global_Q_State_Action = zeros(N_States, N_Actions, N_glob_epoch);
    Global_State_Value = zeros(1, N_States, N_glob_epoch);
    Q_State_Action = zeros(N_States, N_Actions);
    N_State_Action= zeros(N_States, N_Actions);
    State_Value  = zeros(1,N_States);


    for k=1:N_glob_epoch

        disp(['Epoch = ', num2str(k)])
        N_trials = 10000;
        State = 1;
        N_samples = N_trials * 10;

      
        State_time = zeros(1,N_samples);
        Reward_time= zeros(1,N_samples);
        Value_time = zeros(1,N_samples);
        Action_time= zeros(1,N_samples);
        index =1;
        final_state = find(strcmp( "Out_of_Charge",state_names) );

        for i = 1: N_trials

           %init at state 1
            State = 1;
            State_time(index)= State;  
            Value_time(index) = 0;
            action = Choose_Action_Greedy(Q_State_Action, State, epsilon, N_Actions);
            action_time(index)=action;

            while State ~= final_state % Out_of_charge

                 N_State_Action(State, action)= N_State_Action(State, action) +1 ;

                reward = Reward_State_Action(State, action);

                New_State = State_Transition(Transition_Matrix, State, action);

                if(New_State ==final_state)
                  reward = min(min(Reward_State_Action));
                end

                new_action = Choose_Action_Greedy(Q_State_Action, New_State, epsilon, N_Actions);

                Q_State_Action (State, action) = Q_State_Action(State, action) + alpha*(reward + gamma * (Q_State_Action(New_State, new_action))-  Q_State_Action (State, action));

                State = New_State;
                action = new_action;

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

     c=clock;
    time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
    filename = strcat('./res/Log/Workspace_EnergySS_Urge_', time_string,'.mat');
    save(filename,'Reward_State_Action', 'Q_State_Action', 'state_names', 'State_Value'); 

    disp("Average Q_State_Action")
    Mean_Q = mean(Global_Q_State_Action,3)
    
    disp("Average State_Value")
    Mean_State_Value = mean(Global_State_Value,3)

    disp("variance Q_State_Action")
    Var_Q_State_Action = Evaluate_Variance__t(Global_Q_State_Action,3)

    disp("variance State_Value")
    Var_State_Value  = Evaluate_Variance__t(Global_State_Value,3)


    Plot_Global_State_Value(Global_State_Value, state_names, 1, './Output/Energy/State_values_Energy_Modes_URGE_')

    Plot_3d_State_Action(Mean_Q, Var_Q_State_Action, 2, state_names,action_names,  './Output/Energy/Q_State_Action_URGE_')



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


function M = Normalize_Rows(Mat)

    SR = sum(Mat');

    for i = 1: size(Mat,1)
       M(i,:) = Mat(i,:)/SR(i) 

    end

end

