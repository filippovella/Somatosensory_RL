function out = Plot_State_Value(Global_State_Value, state_names, fig_n, fig_fname)
    
    out = 0
    c=clock
    time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3))];

    figure(fig_n)
    clf
    hold on
    
    [nr, nc, nm] = size(Global_State_Value)
    ns = size(state_names,1)
    
    if(nr==1 && ns==nc)
        plot(reshape(Global_State_Value(1,1,:),[],1))
        plot(reshape(Global_State_Value(1,2,:),[],1))
        plot(reshape(Global_State_Value(1,3,:),[],1))
        %lgd = legend('State 1', 'State 2', 'State 3')
        lgd = legend(state_names(1), state_names(2), state_names(3))
        lgd.FontSize = 16;
        lgd.Location='southeast'
        print([ fig_fname,'_', time_string ],'-dpng')
        
    elseif(nr ~=1)
        disp('State value should have a single row')
        out=1
    else
        disp(['The number of State should be ', num2str(ns)])
        out=1
    end
    
    return 