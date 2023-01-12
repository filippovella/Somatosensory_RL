function Main

    addpath('./Energy_ActionModes/','-end')
    addpath('./Current_ActionSelection/','-end')
    addpath('./libs/','-end')
    curr_d = pwd
    %Print_Menu()
    
    list = {'Energy Modes','Energy Modes with a urge','Current Drive actions'};
    %[indx,tf] = listdlg('ListString',list,'SelectionMode','single');
     set(0, 'DefaultUICOntrolFontSize', 16)
    [indx,tf] = listdlg('ListString',list,'SelectionMode','single', 'ListSize', [300 100], 'PromptString', 'RL Somatosensory','uh',50);
   
    
    if(indx ==1)
        disp(['Energy Modes']);
        RL_Energy_Modes(curr_d);
    elseif(indx ==2)
        disp(['Energy Modes with a urge']);
        RL_EnergyModes_URGE(curr_d);
    else
        disp(['Current Drive actions']);
        RL_CurrentPain(curr_d);
    end
    
    rmpath('./Energy_ActionModes/','-end')
    rmpath('./Current_ActionSelection/','-end')
    rmpath('./libs/','-end')


return 
