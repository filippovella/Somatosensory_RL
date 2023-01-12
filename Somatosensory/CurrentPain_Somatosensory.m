function  New_Pain = CurrentPain_Somatosensory(This_Current, Pain_threshold,  Prev_Pain, Max_Value, This_time, Prev_time, Tau_Charge, Tau_Discharge)

    if ( This_Current > Pain_threshold )
        %raise the pain perception
        New_Pain = Prev_Pain + (Max_Value - Prev_Pain) * (1 - exp((This_time - Prev_time)/ Tau_Charge));
    else
        %reduce the pain perception
        New_Pain = Prev_Pain *( 1- exp((This_time - Prev_time)/ Tau_Discharge));
    end

    return