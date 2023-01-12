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

%27 Feb: update: 

%2 March update: the stop action is removed

%URGE : the cognitive leve pushes to continue the task instead of
%recharging

%function ReinforcementLearning_GreedPolicy

function RL_EnergyModes_URGE(current_dir)


    addpath('./libs/','-end')
    addpath('./Somatosensory/','-end')
%time_max    = 14400;
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

%threshold_recharge = 100
% Setting the time constants

tau_0 =600/log(0.5);% NORMAL Mode it is supposed to reach half of the charge in 10 mins
tau_1 =(3600*2)/log(0.5); %HUNGRY it is supposed to reach half of the charge in 20 mins
tau_2 =(3600*4)/log(0.5); %STARVED it is supposed to reach half of the charge in 40 mins
tau_3 =(3600*8)/log(0.5); %STOP it is supposed to reach half of the charge in 80 mins


%Four States: Normal, Hungry, Starved, Stop
state_names     =   ["Normal"; "Hungry"; "Starved";  "Out_of_Charge" ];
%state_reward    =   [ 100, 75, 40, -100 ];

action_names    =   ["Full"; "Economy"; "Recharge" ];

N_States = size(state_names,1);
N_Actions = size(action_names,1);

Reward_State_Action_without_URGE=[   100,    50,         -10;
                                    50,    100,        -8;
                                    5,     80,       -4;
                                    -100,   -100,       -100];

%with URGE
Reward_State_Action=[   100,    50,         -50;
                         90,    50,        -40;
                         80,     30,       -30;
                        -100,   -100,       -100];

  %with URGE POISSON                  
Reward_State_Action=[   184,    15,         0;
                         270,    90,       1;
                         224,     168,       8;
                        -100,   -100,       -100];
  
Reward_State_Action_check=Reward_State_Action - 100*ones(4,3)


Reward_State_Action = Load_Energy_Reward_Matrix(N_States, N_Actions, './res/Energy/Reward_StateAction_Energy_URGE.csv');
    

%with poisson 
%lambda_vect = [1,3,5]
%sample_index =[2,4,8];
lambda_vect = [1,2,3]
sample_index =[2,4,8];
% 
%   183.9397   15.3283    0.0091
%   270.6706   90.2235    0.8593
%   224.0418  168.0314    8.1015
%%_______________________________

% lambda_vect = [1.5,2.5,3.5]
% sample_index =[2,4,8];
%  Reward_State_Action=[ 251,   47,    0;
%   257,  134 ,   3;
%   185,  189  , 17];


%251.0214   47.0665    0.1418
 % 256.5156  133.6019    3.1064
 % 184.9590  188.8123   16.8653

%transition matrix for action WORK

Transition_Matrix = Load_Transition_Matrix(N_States, N_States, './res/Energy/Transition_Matrix_Energy_URGE.csv');

if(false)

    Transition_Matrix(:,:,1)=[
        0.4, 0.5,   0.1,     0;
        0,  0.4,    0.5,     0.1;
        0,  0,      0.4,     0.6;
        0,  0,      0,       1];

    %transition matrix for action Economy WORK

    Transition_Matrix(:,:,2)=[
        0.5, 0.4,   0.1,          0;
        0,  0.5,    0.4,        0.1;
        0,  0,      0.7,        0.3;
        0,  0,      0,           1];



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
%Global_Q_State_Action=[]
Global_State_Value = zeros(1, N_States, N_glob_epoch);

for k=1:N_glob_epoch

    %N_trials = 100000
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

            %to evaluate state value
             N_State_Action(State, action)= N_State_Action(State, action) +1 ;

             if(State==2 && verbose_flag)
              disp('State 2')
             end

            %repeat from state Normal to the state Stop
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
   %N_State_Action = normr(N_State_Action)
       N_State_Action_p =  bsxfun(@times, N_State_Action, 1./(sum(N_State_Action, 2)));

        for i= 1:N_States

            for j =1:N_Actions

                State_Value(i) = State_Value(i) +  N_State_Action_p(i,j)* Q_State_Action(i,j);
            end

        end

        if(false)
            disp('Reward State Actions')
            Reward_State_Action
            disp(' Q State vs Actions')

            Q_State_Action
            state_names  
            disp('  State Value')
            State_Value
        end
        %disp (['k = ',num2str(k)]) 
        
        Global_Q_State_Action(:,:,k)=Q_State_Action;
        Global_State_Value(:,:,k) = State_Value;
end
   
 c=clock;
time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
    
%sample_indx=round(linspace(1, final_iter, N_Samples)) 

filename = strcat('./res/Log/Workspace_EnergySS_Urge_', time_string,'.mat');
%save(filename_a)
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

%fun that Set the state according the value of the variable value

function S =  Set_State(state, value, threshold_vect, threshold_recharge)
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
 





%TransitionMat=zeros(N_States, N_States);



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

%
