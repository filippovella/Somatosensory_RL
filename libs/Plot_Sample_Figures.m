function out = Plot_Sample_Figures(final_iter, State_time_mat, reward_mat, Pain_mat, this_reward_mat, working_mode_mat)

            out=0;
            c=clock;
            %time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
            time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];

            %N_Samples = 3 
            %sample_indx = round(linspace(1, final_iter, N_Samples))
            sample_indx = [final_iter];
            mean_param = [1];

         
            for m = 1:size(mean_param,2)

                for i= 1 : size(sample_indx,2)

                    State_time_mat_avg      =  movmean( State_time_mat(sample_indx(i),:), mean_param(m));
                    Reward_mat_avg          =  movmean( reward_mat(sample_indx(i),:), mean_param(m));
                    Pain_mat_avg          =  movmean( Pain_mat(sample_indx(i),:), mean_param(m));
                    Gain_mat_avg          =  movmean( this_reward_mat(sample_indx(i),:), mean_param(m));

                    figure(6)
                    clf
                    hold on 
                    plot(   State_time_mat_avg,'-','LineWidth',3);
                    %plot(   Reward_mat_avg  , 'b-'); 
                    plot(    Pain_mat_avg , 'r-.','LineWidth',2); 
                    
                    lgd = legend('State', 'pain')
                    lgd.FontSize = 16;
                    handle = gca();
                    ha_X = get(gca,'XTickLabel'); 
                    ha_Y = get(gca,'YTickLabel'); 
                    set(gca,'XTickLabel',ha_X,'fontsize',14)
                    set(gca,'YTickLabel',ha_Y,'fontsize',14)
               
                    xlabel('Time','FontSize',16');
                    print(['./Output/Current/Split_reward_','_iter_', num2str(sample_indx(i)),'_avg_', num2str(mean_param(m)),'_', time_string,'_', num2str(sample_indx(i)) ],'-dpng')
                    

                    figure(7)
                    clf
                    hold on
                    plot(Reward_mat_avg,'r:','LineWidth',2);  %rewad -pain
                    %plot(  Pain_mat_avg , 'r-'); 
                    plot( working_mode_mat(sample_indx(i),:), 'b-','LineWidth',3);  
                    lgd = legend( 'Reward', 'Working Mode')
                    lgd.FontSize = 16;
                    handle = gca();
                    ha_X = get(gca,'XTickLabel'); 
                    ha_Y = get(gca,'YTickLabel'); 
                    set(gca,'XTickLabel',ha_X,'fontsize',14)
                    set(gca,'YTickLabel',ha_Y,'fontsize',14)
               
                    print(['./Output/Current/Working_mode_','_iter_', num2str(sample_indx(i)),'_avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')

                    figure(8)
                    clf
                    hold on
                    plot( Reward_mat_avg,'b-');  %rewad -pain
                    plot(  Pain_mat_avg , 'r-'); 
                    %plot( State_time_mat_avg  ,'-');
                    legend( 'Reward', 'Pain', 'Pain State')
                    print(['./Output/Current/Pain_State','_iter_', num2str(sample_indx(i)),'_avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')



                    figure(9)
                    clf
                    hold on
                    dx =  working_mode_mat(sample_indx(i),2:end) - working_mode_mat(sample_indx(i),1:end-1)
                    dy =  State_time_mat(sample_indx(i),2:end) - State_time_mat(sample_indx(i),1:end-1) 

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
                    print(['./Output/Current/Q_','_iter_', num2str(sample_indx(i)),time_string,'_', num2str(sample_indx(i))],'-dpng')


                    if(false)
                        figure(10)
                        clf
                        hold on

                        plot(  Gain_mat_avg , ':');
                        plot(  Pain_mat_avg , 'r.'); 
                        plot( Reward_mat_avg, 'b-'); 
                        legend( 'Gain', 'Pain', 'Reward')

                        print(['./Output/Current/Gain_Pain_Rew_','iter_', num2str(sample_indx(i)), '_avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')
                   end
                %normalize according the number of chosen actions

                end %n samples
            end %mov mean
            
            
return



