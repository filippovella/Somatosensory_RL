function Plot_State_Value (State_Value, i, tag)

    figure(11)
    clf
    plot(State_Value(1:i,:), 'LineWidth', 3, 'LineStyle', '-')

    % title('State Value');
    lgd = legend({'Normal', 'Tired', 'Aching'}, 'Location','southeast');
    lgd.FontSize = 16;
    y_lower = min(min(State_Value(1:i,:)))
    y_upper = max(max(State_Value(1:i,:)))
    ylim([min(-10, y_lower) max(3, y_upper)])
    %ylim([-10 3])
    xlim([0 200])
    xlabel('training iter','FontSize',16','FontWeight','bold');
    ylabel('Value','FontSize',16,'FontWeight','bold')
    %print(['./imgs/State_Value',num2str(i)],'-dpng')
    print(['./Output/Current/State_Value_',num2str(i),tag],'-dpng')

end

