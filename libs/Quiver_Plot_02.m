 
this_time_string  ="time_2021_4_22_11_37"
filename = ['WS_Current_SS_', this_time_string, '.mat'];
 c=clock
new_time_string = ['time_', num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))];
    
%sample_indx=round(linspace(1, final_iter, N_Samples)) 

filename_a = strcat(filename(1), filename(2), filename(3))
load(filename_a);

sample_indx=[1:100]; 

N_Samples = max(size(sample_indx));
dx_glob =[];
dy_glob =[];
working_mode_mat_glob=[];
State_time_mat_glob=[];

dx_glob_Hor = [];
dy_glob_Hor = [];
working_mode_mat_glob_Hor =[];
State_time_mat_glob_Hor =[];

U = [];
V = [];
dU = [];
dV=[];



if(false)
    Fantastic4_Mat = zeros( N_Actions, N_States, N_Actions, N_States);


    for i = 1: size(working_mode_mat,1)
        for t = 1: size(working_mode_mat,2)-1
            disp(['i = ', num2str(i),', t = ',  num2str(t)]);
            Curr_Mode = working_mode_mat(i,t);
            Next_Mode = working_mode_mat(i,t+1);

            Curr_State = State_time_mat(i,t);
            Next_State = State_time_mat(i,t+1);

            U = [U; Curr_Mode];
            V = [V; Curr_State];
            dU = [dU; Next_Mode - Curr_Mode];
            dV = [dV; Next_State - Curr_State ];

            if(i==5 && t ==118)
                keyboard
            end
            if(Curr_Mode>0 && Curr_State>0 &&  Next_Mode>0 &&  Next_State>0 )
                Fantastic4_Mat(Curr_Mode, Curr_State, Next_Mode, Next_State) = Fantastic4_Mat(Curr_Mode, Curr_State, Next_Mode, Next_State) +1;
            end
        end
    end
else
    
    filename = ['./workspace_Quiver_Plot_01.mat']
    load ( filename)
end

Normalized_F4Mat = Normalize_Mat_to_targets (Fantastic4_Mat, N_Actions, N_States)

%Normalized_F4Mat_State = Normalize_Mat_States (Fantastic4_Mat, N_Actions, N_States)

U = [];
V = [];
dU = [];
dV=[];

for i = 1: N_Actions
     for j = 1: N_States

         %state_origin = 4-j; 
         
         for k = 1: N_Actions
            for l = 1: N_States
                U = [U; i];
                V = [V; j];
               % state_target = 4 - l;
                
                dU = [dU; Normalized_F4Mat(i,j,k,l)*(k-i)];
                dV = [dV; Normalized_F4Mat(i,j,k,l)*(l-j)];
            end
         end

         
         
     end
 end


figure(103)
clf
q4= quiver(U,V,dU,dV)
set(q4, 'AutoScale','on', 'AutoScaleFactor', 2)
q4.ShowArrowHead = 'on';
q4.Marker = '.';
q4.Marker = 'o';
handle = gca();
handle.XTick = [0 1 2 3]
handle.YTick = [0 1 2 3]

    %xticks([0 1 2 3])
   % xticklabels({'','Mode 1 (expensive)','Mode 2 (mixed)','Mode 3 (relaxing)'})
handle.YLim= [0.8 3.2]
handle.XLim=[0.8 3.2]
    yticks([0 1 2 3])
   % yticklabels({'','Normal','Tired','Aching'})
  
%handle.YTickLabel =  {'', 'Normal','Tired','Aching'};
    %%%

row1 = { '' 'Mode 1' 'Mode 2' 'Mode 3'};
row2 = { '' '(expensive)' '(mixed)' '(relaxing)' };

labelArray = [row1; row2]; 
tick_X_Labels = strtrim(sprintf('%s\\newline%s\\newline\n', labelArray{:}));
handle.XTickLabel = tick_X_Labels

ha_X = get(gca,'XTickLabel'); 
ha_Y = get(gca,'YTickLabel'); 
set(gca,'XTickLabel',ha_X,'fontsize',16,'FontWeight','bold')
set(gca,'YTickLabel',ha_Y,'fontsize',16,'FontWeight','bold')

print(['./imgs/Q_S_arrow_',new_time_string,'_', num2str(sample_indx(i))],'-dpng')

    %%%
keyboard



for i= 1 : N_Samples
    dx =  working_mode_mat(sample_indx(i),2:end) - working_mode_mat(sample_indx(i),1:end-1);
    dy =  State_time_mat(sample_indx(i),2:end) - State_time_mat(sample_indx(i),1:end-1) ;
    
    
    dx_glob= [dx_glob; dx];
    dy_glob= [dy_glob; dy];
    working_mode_mat_glob =  [working_mode_mat_glob; working_mode_mat(sample_indx(i),1:end-1)];
    State_time_mat_glob = [State_time_mat_glob; State_time_mat(sample_indx(i),1:end-1)];
    
    dx_glob_Hor = [dx_glob_Hor, dx]
    dy_glob_Hor = [dy_glob_Hor, dy]

    working_mode_mat_glob_Hor   = [working_mode_mat_glob_Hor, working_mode_mat(sample_indx(i),1:end-1)];
    State_time_mat_glob_Hor     = [State_time_mat_glob_Hor, State_time_mat(sample_indx(i),1:end-1)];
    
    figure(100)
    clf
    %q1 = quiver(  working_mode_mat_Mean(1:end-1),  State_time_mat_Mean(1:end-1), 4*dx, 4*dy)
    q1 = quiver(  working_mode_mat(sample_indx(i),1:end-1),  State_time_mat(sample_indx(i),1:end-1), 4*dx, 4*dy)
    set(q1, 'AutoScale','on', 'AutoScaleFactor', 2)
    
    
    if(mod(1,100)==0)
        figure(101)
        clf
        dx_median =median(dx_glob);
        dy_median =median(dx_glob);
   
        q2 = quiver(  median(working_mode_mat_glob),  median(State_time_mat_glob), 4.*dx_median, 4.*dy_median)
        set(q2, 'AutoScale','on', 'AutoScaleFactor', 2)
        title('median')
        
        figure(102)
        clf
        q3 = quiver(  working_mode_mat_glob_Hor,  State_time_mat_glob_Hor, 4.*dx_glob_Hor, 4.*dy_glob_Hor)
        %set(q3, 'AutoScale','on', 'AutoScaleFactor', 2)
        title('Global Quiver')
        xticks([0 1 2 3])
        xticklabels({'','Mode 1 (expensive)','Mode 2 (mixed)','Mode 3 (relaxing)'})
        ylim([0.8 3.2])
        xlim([0.8 3.2])
        yticks([0 1 2 3])
        yticklabels({'','Normal','Tired','Aching'})
        print(['./imgs/Q_',new_time_string,'_', num2str(sample_indx(i))],'-dpng')

        
        
    end
end

    figure(102)
    clf
    q3 = quiver(  working_mode_mat_glob_Hor,  State_time_mat_glob_Hor, 4.*dx_glob_Hor, 4.*dy_glob_Hor)
    set(q3, 'AutoScale','on', 'AutoScaleFactor', 2)
    title('Global Quiver')
    xticks([0 1 2 3])
    xticklabels({'','Mode 1 (expensive)','Mode 2 (mixed)','Mode 3 (relaxing)'})
    ylim([0.8 3.2])
    xlim([0.8 3.2])
    yticks([0 1 2 3])
    yticklabels({'','Normal','Tired','Aching'})
    print(['./imgs/Q_FINAL_',new_time_string,'_', num2str(sample_indx(i))],'-dpng')


    Single_Vect_Delta = 100.*dx_glob_Hor+dy_glob_Hor;
    

    Mov_Freqs=zeros(4,5)
    for i =1: size(dx_glob_Hor,2)
       
        indx_x = dx_glob_Hor(i) +3;
        indx_y = 3- dy_glob_Hor(i);
        if(indx_y <= 4 && indx_x <=5 && indx_y >=0 && indx_x>=0)
        %Mov_Freqs(indx_x, indx_y) =  Mov_Freqs(indx_x, indx_y)+1;
            Mov_Freqs(indx_y,indx_x) =    Mov_Freqs(indx_y,indx_x) + 1 ;
        end
    end
    
    Mov_Freqs = log(Mov_Freqs)
    
%     U = [];
%     V = [];
%     dU = [];
%     dV=[];
%     
%     for i = 1: N_States
%         for j = 1: N_Actions
%             
%            U = [U; i];
%            V = [V; j];
%            dU=
%            
%            dV=
%            
%             
%             
%         end
%     end
%    
%     


    dx_mean =mean(dx_glob);
    dy_mean =mean(dx_glob);
    working_mode_mat_Mean = mean(working_mode_mat);
    State_time_mat_Mean = mean ( State_time_mat);
 
    figure(100)
    clf
    q1 = quiver(  working_mode_mat_Mean(1:end-1),  State_time_mat_Mean(1:end-1), 4*dx, 4*dy)
    %q1 = quiver(  working_mode_mat(sample_indx(i),1:end-1),  State_time_mat(sample_indx(i),1:end-1), 4*dx, 4*dy)
    title('Quiver')
    set(q1, 'AutoScale','on', 'AutoScaleFactor', 2)
    set(q1, 'LineWidth', 2)
    xlabel('Working Mode');
    ylabel('Pain State')
    xlim([0.8 3.2])
    xticks([0 1 2 3])
    xticklabels({'','Mode 1\\newline(expensive)','Mode 2\\newline(mixed)','Mode 3\\newline(relaxing)'})
    ylim([0.8 3.2])
    yticks([0 1 2 3])
    yticklabels({'','Normal','Tired','Aching'})
    yticklabels.FontSize = 16;
  
    print(['./imgs/Q_',new_time_string,'_', num2str(sample_indx(i))],'-dpng')
    
    
function Normalized_F4Mat = Normalize_Mat_to_targets (Fantastic4_Mat, N_Actions, N_States)
    

 Normalized_F4Mat = zeros( N_Actions, N_States, N_Actions, N_States);
 
 log_compress=true
 
 for i = 1: N_Actions
     for j = 1: N_States

         My_Mat = Fantastic4_Mat(i,j, :,:);
         My_Mat = reshape(My_Mat,N_Actions, N_States);
         
         if(log_compress)
             nn_index = find (My_Mat ~=0);
             My_Mat(nn_index) = log( My_Mat(nn_index));
         end 
         S = sum(sum(My_Mat));
         
         My_Mat = My_Mat./S;
         
         for k = 1: N_Actions
            for l = 1: N_States
                Normalized_F4Mat(i,j, k,l ) =My_Mat(k,l);
            end
         end

         
         
     end
 end


end

   
function Normalized_F4Mat = Normalize_Mat_States (Fantastic4_Mat, N_Actions, N_States)
    

 Normalized_F4Mat = zeros( N_Actions, N_States, N_Actions, N_States);
 
 log_compress=false
 
 for i = 1: N_Actions
     for j = 1: N_States

         My_Mat = Fantastic4_Mat(i,j, :,:);
         My_Mat = reshape(My_Mat,N_Actions, N_States);
         
         if(log_compress)
             nn_index = find (My_Mat ~=0)
             My_Mat(nn_index) = log( My_Mat(nn_index))
         end 
         S = sum(sum(My_Mat));
         
         My_Mat = My_Mat./S;
         
         for k = 1: N_Actions
            for l = 1: N_States
                Normalized_F4Mat(i,j, k,l ) = My_Mat(k,l);
            end
         end

         
         
     end
 end


end
    