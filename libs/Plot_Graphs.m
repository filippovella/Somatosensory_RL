
%Plot_Figures

  time_string = 'time_2019_1_14_17_34'
   time_string ='time_2019_1_15_18_45'
    filename = ['workspace', time_string, '.mat'];
    load(filename)
    
    mean_param =[1]
    
    
    figure_4_flag=0
    figure_5_flag=1
    figure_6_flag=0
    figure_7_flag=1
    figure_8_flag=0
    
    
    for i = 1:size(mean_param,2)
        
        figure(1)
        clf
     
        Final_time_index_avg = movmean(Final_time_index(1:final_iter), mean_param(i));
        col =  Final_time_index_avg;
     
        scatter(1:final_iter,  Final_time_index_avg,  mean_param(i));
   
        print(['Final_time_avg_',  time_string, '_', num2str(mean_param(i))],'-dpng')
        title('Time Lenght')

        figure(2)
        clf

        Final_reward_index_avg = movmean(Final_reward(1:final_iter), mean_param(i));
        col =  Final_reward_index_avg;
     
        scatter(1:final_iter,  Final_reward_index_avg,  mean_param(i));
        %set(gca,'yscale','log')
         print(['Final_reward_index_avg',time_string, '_', num2str(mean_param(i))],'-dpng')
         title('Reward')
    

    end
    
    figure(3)
    clf
    plot(mean(reward_mat))
    xlabel('Time');
    ylabel('Mean Reward');
    print(['Mean_reward_',time_string, ],'-dpng')
    
     figure(9)
     clf
    plot(mean(Pain_mat))
    xlabel('Time');
    ylabel('Mean Pain');
    print(['Mean_Pain_',time_string, ],'-dpng')
    
     figure(10)
     clf
    plot(working_mode_mat(1:final_iter,:))
    xlabel('Time');
    ylabel('Mean Working mode');
    print(['Working_mode_',time_string, ],'-dpng')
    
     figure(11)
     clf
    plot(mean(State_time_mat))
    xlabel('Time');
    ylabel('Mean State time');
    print(['State_time_',time_string, ],'-dpng')
    
    N_Samples = 10 
    sample_indx=round(linspace(1, final_iter, N_Samples))
    %mean_param =[1 10 20 40]
    mean_param =[1]
    
    for m = 1:size(mean_param,2)
        
        for i= 1 : N_Samples

            
            State_time_mat_avg      =  movmean( State_time_mat(sample_indx(i),:), mean_param(m));
            Reward_mat_avg          =  movmean( reward_mat(sample_indx(i),:), mean_param(m));
            Pain_mat_avg            =  movmean( Pain_mat(sample_indx(i),:), mean_param(m));
            Gain_mat_avg            =  movmean( this_reward_mat(sample_indx(i),:), mean_param(m));
            
            if figure_4_flag
                figure(4)
                clf
                hold on 
                plot(   State_time_mat_avg,'-');
                plot(   Reward_mat_avg  , 'b-'); 
                plot(    Pain_mat_avg , 'r-'); 
                legend('Pain State', 'reward', 'pain')
                print(['Split_reward_','avg_', num2str(mean_param(m)),'_', time_string,'_', num2str(sample_indx(i)) ],'-dpng')
            end
            
            if figure_5_flag
                figure(5)
                clf
                hold on
                plot(Reward_mat_avg,'b-');  %rewad -pain
                plot(  Pain_mat_avg , 'r-'); 
                plot( working_mode_mat(sample_indx(i),:)); 
                legend( 'Reward', 'Pain', 'Working Mode')
                print(['Working_mode_','avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')
                
            end 
            
            if figure_6_flag

                figure(6)
                clf
                hold on
                plot( Reward_mat_avg,'b-');  %rewad -pain
                plot(  Pain_mat_avg , 'r-'); 
                plot( State_time_mat_avg  ,'-');
                legend( 'Reward', 'Pain', 'Pain State')
                print(['Pain_State','avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')
            end

            if figure_7_flag
                figure(7)
                clf
                hold on
                dx =  working_mode_mat(sample_indx(i),2:end) - working_mode_mat(sample_indx(i),1:end-1);
                dy =  State_time_mat(sample_indx(i),2:end) - State_time_mat(sample_indx(i),1:end-1) ;

                q1 = quiver(  working_mode_mat(sample_indx(i),1:end-1),  State_time_mat(sample_indx(i),1:end-1), 4*dx, 4*dy)
                set(q1, 'AutoScale','on', 'AutoScaleFactor', 2)
                set(q1, 'LineWidth', 2)
                xlabel('Working Mode');
                ylabel('Pain State')
                xlim([0.8 3.2])
                xticks([0 1 2 3])
                xticklabels({'','Mode 1 (expensive)','Mode 2 (mixed)','Mode 3 (relaxing)'})
                ylim([0.8 3.2])
                yticks([0 1 2 3])
                yticklabels({'','Normal','Tired','Aching'})
                print(['Q_',time_string,'_', num2str(sample_indx(i))],'-dpng')
            end
            
            if figure_8_flag
                figure(8)
                clf
                hold on

                plot(  Gain_mat_avg , ':');

                plot(  Pain_mat_avg , 'r.'); 
                plot( Reward_mat_avg, 'b-'); 
                legend( 'Gain', 'Pain', 'Reward')

                print(['Gain_Pain_Rew_','avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')
            end
        %normalize according the number of chosen actions


        end
    end
    

        %N_State_Action = normr(N_State_Action)


    disp(' Q State vs Actions')

    Q_State_Action

    disp('  State Value')
  
    State_Value_Stat = State_Value(final_iter-10:final_iter,:)
    %State_Value
    figure(11)
    clf
    plot(State_Value(1:final_iter,:))
    legend({'Normal', 'Tired','Aching'}, 'Location','southeast')
       
    print(['State_Value',num2str(final_iter)],'-dpng')
    title('State Value')
    

    keyboard