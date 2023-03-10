

%
% Experiment for the selection of energy modes according to the Energy Roboception

% The experiment is described in "Behavior Mode Selection through Reinforcement Learning" 

% by 

% Agnese Augello,Salvatore Gaglio,Ignazio Infantino,Umberto Maniscalco,Giovanni Pilato,Filippo Vella



%function ReinforcementLearning_GreedPolicy

function RL_Energy_Modes(current_dir)

    Max_Value   = 100;
    n_step      = 100;

    threshold_recharge = 98;
    tau_filename = './res/Energy/Tau_values.csv';
    charge_th_filename = './res/Energy/Charge_th.csv';
    tau_value = csvread(tau_filename);
    charge_th=csvread(charge_th_filename);
    
    state_names     =   ["Normal"; "Hungry"; "Starved";  "Out of Charge"];
    action_names    =   ["Full"; "Economy"; "Recharge" ];

    N_States = size(state_names,1);
    N_Actions = size(action_names,1);


    Reward_State_Action = Load_Energy_Reward_Matrix(N_States, N_Actions, './res/Energy/Reward_StateAction_Energy.csv');
    Transition_Matrix = Load_Transition_Matrix(N_States, N_States, './res/Energy/Transition_Matrix_Energy.csv');
    
    Q_State_Action = zeros(N_States, N_Actions);
    N_State_Action= zeros(N_States, N_Actions);
    State_Value  = zeros(1,N_States);

    %RL Params
    alpha = 0.5;
    epsilon = 0.2;
    gamma = 0.7;
     
    N_glob_epoch = 5 ; %1000

    Global_Q_State_Action = zeros(N_States, N_Actions, N_glob_epoch);
    Global_State_Value = zeros(1,N_States, N_glob_epoch);
  
    for k=1:N_glob_epoch

        disp(['Epoch = ', num2str(k)])
        N_trials = 10000;
        State = 1;
        N_samples = N_trials * 10;
        
        Q_State_Action = zeros(N_States, N_Actions);
        N_State_Action= zeros(N_States, N_Actions);
        State_Value  = zeros(1,N_States);

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
            Action_time(index)=action;

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
                Action_time(index)= action;
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

        Global_Q_State_Action(:,:,k) = Q_State_Action;
        Global_State_Value(:,:,k) = State_Value;
    end

    c=clock;
    time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];

    disp('Reward State Actions')
    Reward_State_Action
    disp(' Q State vs Actions')

    disp(' State Value')
    State_Value

    filename = ['./res/Log/Energy/WS_Energy_SS_', time_string, '.mat'];
    save(filename,'Reward_State_Action', 'Q_State_Action', 'state_names', 'State_Value') 

    disp("Average Q_State_Action")
    Mean_Q = mean(Global_Q_State_Action,3)
    disp("Average State_Value")
    Mean_State_Value = mean(Global_State_Value,3)

    disp("variance Q_State_Action")
    Var_Q_State_Action = Evaluate_Variance__t(Global_Q_State_Action,3)

    disp("variance State_Value")
    Var_State_Value  = Evaluate_Variance__t(Global_State_Value,3)


    Plot_Global_State_Value(Global_State_Value, state_names, 1, './Output/Energy/State_values_Energy_Modes')

    Plot_3d_State_Action(Mean_Q, Var_Q_State_Action, 2, state_names,action_names,  './Output/Energy/Q_State_Action_')




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

%fun Set_State modify the state according to value

function [S, New_Charge] = Set_State(state, action, current, Charge, charge_th, threshold_recharge, action_names)

% this function was used in place of State_Transition, the state
% modification have been characterized by the transition matrices that 
% resemble the state change according to these evolutions

    dbg = 0
    Max_Current = 1.0;
    Max_Charge=1.0;
    Charge=1.0;
    Inhibition = 0.0;
    Modulation = 1.0;

    if(action ==1)
        This_Current=1.0;
        New_Charge = Charge *( 1- exp((This_time - Prev_time)/ Tau_Discharge));
    elseif(action ==2)
        This_Current=0.6;
    else
        
        
    end
    
    This_Exertion = Energy_Somatosensory(This_Current, Max_Current, Charge, Max_Charge,  Modulation, Inhibition)
        
    %state 4 is recharge

    if( Charge < charge_th(4))
        if(This_Exertion > 0.80)
            S = 4; %Out of Charge
        else
            S = 3; %"Starved"
        end
    elseif( Charge < charge_th(3))
         if(This_Exertion > 0.90)
            S = 4; %Out of Charge
         else
            S = 3; %"Starved"
         end
    elseif( Charge < charge_th(2))
        if(This_Exertion > 0.90)
            S = 3; %Out of Charge
         else
            S = 2; %"Starved"
        end
    else
        if(This_Exertion > 0.99)
            S = 3; %Out of Charge
         elseif(This_Exertion > 0.80)
            S = 2; %"Starved"
        else
            S=1;
        end
        
    end
        
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
