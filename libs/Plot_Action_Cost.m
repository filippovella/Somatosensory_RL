 function out = Plot_Action_Cost(Action_Reward, Action_Cost, N_Actions, n_steps)
      
        out = 1
        for j=1 : N_Actions

            figure(j);
            clf
            hold on
            subplot(2,1,1)                  % add first plot in 2 x 2 grid
            plot((1:n_steps),Action_Reward(j,:))           
            ylim([0 1.2]);
            title('Reward vs time')

            subplot(2,1,2)                  % add second plot in 2 x 2 grid

            plot((1:n_steps),Action_Cost(j)*ones(1,n_steps)  )        
               ylim([-0.5 2.5]);
            title('Cost vs time')

            print(['Action_',num2str(j)],'-dpng')


        end
return