function Plot_3d_State_Action(Mean_Q, Var_Q_State_Action, fig_n, state_names, action_names, fname_fig)

    c=clock;
    time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];
    N_States = size(state_names,1);
    N_Actions = size(action_names,1);

    figure(fig_n)
    clf
    bar3(Mean_Q);
    xlabel('Action','FontSize',16,'Color','black')
    ylabel('State','FontSize',16,'Color','black')
    for i=1:N_States
       indx=strfind(state_names(i),'_');
       if(~isempty(indx))
            state_names(i) = strrep(state_names(i),'_', ' ')
       end
        
    end

    xticklabels({action_names(1),action_names(3),action_names(3)})
    yticklabels({state_names(1), state_names(2), state_names(3),state_names(4)})
    %print([fname_fig,'_', time_string ],'-dpng')
    hold on

    for j = 1:N_States , 
        for i = 1:N_Actions, 
            
            z35 = Mean_Q(j,i):Mean_Q(j,i)/100:Mean_Q(j,i)+sqrt(Var_Q_State_Action(j,i)) ;
            x35(1:length(z35)) = j; 
            y35(1:length(z35)) = i; 
            plot3(y35, x35, z35,'r-') 
            clear x35; clear y35; clear z35; 
        end 
    end 
    print([fname_fig,'_v1_', time_string ],'-dpng')
    
     
