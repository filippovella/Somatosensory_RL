%Implementation of the Energy Softsensor. It is function of the corrent given by the battery

% If inhibition is one, exertion is zero

% Inhibition paramenter is from 0 to 1

%The modulation parameter is used to module the soft sensor value its value
%is between 0 and 1



function  Exertion = Energy_Somatosensory(This_Current, Max_Current, Charge, Max_Charge,  Modulation, Inhibition)

    Inhibition = min(Inhibition, 1.0);
    Inhibition = max (Inhibition, 0.0);

    Modulation  = min(Modulation, 1.0);
    Modulationn = max (Modulation, 0.0);
    
    This_Current = min(This_Current, Max_Current);
    This_Current = max(This_Current, 0);
    
    Charge =min(Charge, Max_Charge);
    
    Charge =max(Max_Charge, 0);

    Exertion = Modulation*(1-Inhibition)*2*atan(This_Current*Max_Charge/Charge/Max_Current)/pi;

    return