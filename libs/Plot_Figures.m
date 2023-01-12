function out = Plot_Figures(final_iter, Final_time_index, Final_reward, reward_mat, Pain_mat, State_time_mat)
        out = 0
        %mean_param =[1 10 20]
        c=clock
        %time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
        time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];

            mean_param =[20]

            for i = 1:size(mean_param,2)

                figure(1)
                clf

                Final_time_index_avg = movmean(Final_time_index(1:final_iter), mean_param(i));
                %col =  Final_time_index_avg;

                scatter(1:final_iter,  Final_time_index_avg,  mean_param(i));
                xlabel('epochs','FontSize', 16','FontWeight','bold');
                ylabel('sec',   'FontSize', 16','FontWeight','bold');
               
                handle = gca();
                handle.XTick = linspace(0,800,4)
                handle.XTick = 0:200:800
                %handle.XLim= [0.8 3.2]
                handle.YLim=[110.0 124.0]
                ha_X = get(gca,'XTickLabel'); 
                ha_Y = get(gca,'YTickLabel'); 
                set(gca,'XTickLabel',ha_X,'fontsize',14,'FontWeight','bold')
                set(gca,'YTickLabel',ha_Y,'fontsize',14,'FontWeight','bold')
             
                % print(['./imgs/Final_time_avg_',  time_string, '_', num2str(mean_param(i))],'-dpng')
                title(['Time Length ',  'mov mean (',num2str(mean_param(i)),')'])
                print(['./Output/Current/Final_time_avg_',  time_string, '_', num2str(mean_param(i))],'-dpng')
         
               
                figure(2)
                clf

                Final_reward_index_avg = movmean(Final_reward(1:final_iter), mean_param(i));
                col =  Final_reward_index_avg;

                scatter(1:final_iter,  Final_reward_index_avg,  mean_param(i));
                handle.XTick = 0:200:800

                ha_X = get(gca,'XTickLabel'); 
                ha_Y = get(gca,'YTickLabel'); 
                set(gca,'XTickLabel',ha_X,'fontsize',16,'FontWeight','bold')
                set(gca,'YTickLabel',ha_Y,'fontsize',16,'FontWeight','bold')
                title(['Reward ',  'mov mean (',num2str(mean_param(i)),')'])
                print(['./Output/Current/Final_reward_index_avg',time_string, '_', num2str(mean_param(i))],'-dpng')
                 
                figure(3)
                clf
                plot(mean(reward_mat), 'LineWidth',2,'LineStyle','-')
                xlabel('Time');
                ylabel('Mean Reward');
                title(['Mean Reward '])
                print(['./Output/Current/Mean_reward_',time_string, ],'-dpng')

                figure(4)
                clf
                plot(mean(Pain_mat), 'LineWidth',3)
                xlabel('Time');
                ylabel('Mean Pain');
                title(['Mean Pain'])
                print(['./Output/Current/Mean_Pain_3_',time_string, ],'-dpng')

            end
        
           
            if(0) 
                figure(10)
                clf
                plot(working_mode_mat(1:final_iter,:))
                xlabel('Time');
                ylabel('Mean Working mode');
                print(['./Output/Current/Working_mode_', time_string, ],'-dpng')
            end

            figure(5)
            clf
            plot(mean(State_time_mat), 'LineWidth', 3, 'LineStyle', '-')%, 'LineWidth', 3, 'LineStyle', '-'
            xlabel('Time');
            ylabel('Mean Pain State ');
            title(['Mean Pain State vs time'])
            print(['./Output/Current/Pain_State_vs_time_', time_string, ],'-dpng')

            %figure(100)
            %working_mode_mat

            if(false)
                for m = 1:size(mean_param,2)

                    for i= 1 : N_Samples

                        State_time_mat_avg      =  movmean( State_time_mat(sample_indx(i),:), mean_param(m));
                        Reward_mat_avg          =  movmean( reward_mat(sample_indx(i),:), mean_param(m));
                        Pain_mat_avg          =  movmean( Pain_mat(sample_indx(i),:), mean_param(m));
                        Gain_mat_avg          =  movmean( this_reward_mat(sample_indx(i),:), mean_param(m));

                        figure(6)
                        clf
                        hold on 
                        plot(   State_time_mat_avg,'-','LineWidth',3);
                        plot(    Pain_mat_avg , 'r-.','LineWidth',2); 
                      
                        lgd = legend('State', 'pain')
                        lgd.FontSize = 16;
                             
                        handle = gca();
                        ha_X = get(gca,'XTickLabel'); ha_Y = get(gca,'YTickLabel'); 
                        set(gca,'XTickLabel',ha_X,'fontsize',14);set(gca,'YTickLabel',ha_Y,'fontsize',14);
                        xlabel('Time','FontSize',16');
                        print(['./Output/Current/Split_reward_','avg_', num2str(mean_param(m)),'_', time_string,'_', num2str(sample_indx(i)) ],'-dpng')



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

                        print(['./Output/Current/Working_mode_','avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')

                        figure(8)
                        clf
                        hold on
                        plot( Reward_mat_avg,'b-');  %rewad -pain
                        plot(  Pain_mat_avg , 'r-'); 
                        plot( State_time_mat_avg  ,'-');
                        legend( 'Reward', 'Pain', 'Pain State')
                        print(['./Output/Current/Pain_State','avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')



                        figure(9)
                        clf
                        hold on
                        dx =  working_mode_mat(sample_indx(i),2:end) - working_mode_mat(sample_indx(i),1:end-1)
                        dy =  State_time_mat(sample_indx(i),2:end) - State_time_mat(sample_indx(i),1:end-1) 

                        q1 = quiver(  working_mode_mat(sample_indx(i),1:end-1),  State_time_mat(sample_indx(i),1:end-1), 4*dx, 4*dy)
                        set(q1, 'AutoScale','on', 'AutoScaleFactor', 2);
                        set(q1, 'LineWidth', 2);
                        xlabel('Working Mode');
                        ylabel('Pain State');
                        xlim([0.8 3.2]);
                        xticks([0 1 2 3]);
                        xticklabels({'','Mode 1 (expensive)','Mode 2 (mixed)','Mode 3 (relaxing)'});
                        ylim([0.8 3.2]);
                        yticks([0 1 2 3]);
                        yticklabels({'','Normal','Tired','Aching'})
                        print(['./Output/Current/Q_',time_string,'_', num2str(sample_indx(i))],'-dpng')


                        figure(10)
                        clf
                        hold on

                        plot(  Gain_mat_avg , ':');
                        plot(  Pain_mat_avg , 'r.'); 
                        plot( Reward_mat_avg, 'b-'); 
                        legend( 'Gain', 'Pain', 'Reward')

                        print(['./Output/Current/Gain_Pain_Rew_','avg_', num2str(mean_param(m)),'_',time_string,'_', num2str(sample_indx(i))],'-dpng')

                    %normalize according the number of chosen actions

                    end %n samples
                end %mov mean

            end
            
return



