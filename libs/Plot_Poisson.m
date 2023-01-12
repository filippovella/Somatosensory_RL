function Plot_Poisson

%lambda_vect = [2,4,6]
lambda_vect = [3,5,7]
sample_index =[2,4,8];
Stored_Samples =[];
x = 1:30;


figure(1);
clf;
hold on

Color_Vect=[1.0, 0.0, 0.0; 0.0, 1.0, 0.0; 0.0, 0.0, 1.0];

for i = 1:size(lambda_vect,2)

    global_y=[];
    y =  1000*fun_poisson(lambda_vect(i),x);
    plot(x,y, 'LineWidth',2,'LineStyle',':','Color',Color_Vect(i,:));
    global_y =[global_y ;y] ;
    y_sample = global_y(:, sample_index);
    Stored_Samples =[Stored_Samples; y_sample];
    %plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:));
     if (i ==1)
           plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:), 'MarkerSize', 5);
     elseif(i==2)
            plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:), 'MarkerSize', 5);
     else
            plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:), 'MarkerSize', 5);
        
    end
    ylim([0 400])
    xlim([0 15])
end

Stored_Samples
Stored_Samples=[];
%lambda_vect = [1,3,5]
%lambda_vect = [1.5,2.5,3.5]
lambda_vect = [1,2,3]
sample_index =[2,4,8];
x = 1:30;


figure(2);
clf;
hold on


for i = 1:size(lambda_vect,2)

    global_y=[];
    y =  1000*fun_poisson(lambda_vect(i),x);
    plot(x,y, 'LineWidth',2,'LineStyle',':','Color',Color_Vect(i,:));
    global_y =[global_y ;y] ;
    y_sample = global_y(:, sample_index);
    Stored_Samples =[Stored_Samples; y_sample];
    if (i ==1)
        plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:), 'MarkerSize', 5);
    elseif(i==2)
        plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:), 'MarkerSize', 5);
    else
        plot(sample_index,y_sample,'o','Color',Color_Vect(i,:),'MarkerFaceColor',Color_Vect(i,:), 'MarkerSize', 5);
        
    end
    ylim([0 400])
    xlim([0 15])
end

Stored_Samples



return



function y = fun_poisson(l, x)

    fact = exp(-l);
    y = zeros(size(x));
    for i = 1:size(x,2)
        y(i) = fact * l^(x(i))/factorial(x(i));
    end
return


