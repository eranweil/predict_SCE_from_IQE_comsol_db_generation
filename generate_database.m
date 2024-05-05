
% Base directory for saving results
base_directory = 'C:\Users\Itamar & Eran\Eran Masters\';

% Add the necessary path
addpath(strcat(base_directory,'outside_parameters'));

% Script for running parameter sweeps and generating SCE data

% Record start time
t1 = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
disp(t1); 

% COMSOL Parameters
delta_amplitude_b = 1E20;
sigma = 50E-9;
q = 1.6E-19;
number_of_intervals_in_mesh = 2400;

% Initial and final values for device parameters
L_first = 20;                         L_last = 300;
bulk_doping_first = 1E13;             bulk_doping_last = 1E17;
p0_first = bulk_doping_first * 10;    p0_last = 1E19;
n0_first = bulk_doping_first * 10;    n0_last = 1E19;
taup_first = 1;                       taup_last = 100;
taun_first = 1;                       taun_last = 100;
mup_first = 50;                       mup_last = 5000;
mun_first = 145;                      mun_last = 14500;

% Number of iterations for each parameter sweep
% For Green comparison make all num_iter 1
bulk_doping_num_iter = 10;
junction_doping_num_iter = 10;
lifetime_num_iter = 10;
mobility_num_iter = 10;
device_length_num_iter = 8;

% %%%Green device - uncomment for green comparison
% L_first = 100;
% bulk_doping_first = 1E16;
% p0_first = bulk_doping_first * 100;
% n0_first = bulk_doping_first * 100;
% taup_first = 10;
% taun_first = 10;
% mup_first = 500;
% mun_first = 1450;

% %%%Green device - uncomment for green comparison
% L_first = 140;
% bulk_doping_first = 1E14;
% p0_first = bulk_doping_first * 10000;
% n0_first = bulk_doping_first * 10000;
% taup_first = 100;
% taun_first = 100;
% mup_first = 1077;
% mun_first = 3124;
 
% %%%Green device - uncomment for green comparison
% L_first = 220;
% bulk_doping_first = 1E15;
% p0_first = bulk_doping_first * 10;
% n0_first = bulk_doping_first * 10;
% taup_first = 1;
% taun_first = 1;
% mup_first = 387;
% mun_first = 1123;

% Calculation of jump factors for logarithmic sweeps
if bulk_doping_num_iter > 1
   bulk_doping_jump = 10^((log10(bulk_doping_last/bulk_doping_first))/(bulk_doping_num_iter-1));
else
   bulk_doping_jump = 1;
end
if junction_doping_num_iter > 1
   p0_jump = 10^((log10(p0_last/p0_first))/(junction_doping_num_iter-1));
   n0_jump = 10^((log10(n0_last/n0_first))/(junction_doping_num_iter-1));
else
   p0_jump = 1;
   n0_jump = 1;
end
if lifetime_num_iter > 1
   taup_jump = 10^((log10(taup_last/taup_first))/(lifetime_num_iter-1));
   taun_jump = 10^((log10(taun_last/taun_first))/(lifetime_num_iter-1));
else
   taup_jump = 1;
   taun_jump = 1;
end
if mobility_num_iter > 1
   mup_jump = 10^((log10(mup_last/mup_first))/(mobility_num_iter-1));
   mun_jump = 10^((log10(mun_last/mun_first))/(mobility_num_iter-1));
else
   mup_jump = 1;
   mun_jump = 1;
end
if device_length_num_iter > 1
   device_length_jump = (L_last-L_first)/(device_length_num_iter-1);
else
   device_length_jump = 1;
end

% Helper vectors 
column_one_two = [1;2]; 
vector_25 = 1:1:25;

% Initialize parameters at the start of the loop
bulk_doping = bulk_doping_first;
p0 = p0_first; 
n0 = n0_first;
taup = taup_first;
taun = taun_first;
mup = mup_first;
mun = mun_first;
L = L_first;

for bulk_doping_loop_index = 1:bulk_doping_num_iter
    for junction_concentration_loop_index = 1:junction_doping_num_iter
        for lifetime_loop_index = 1:lifetime_num_iter
            for mobility_loop_index = 1:mobility_num_iter
                for device_length_loop_index = 1:device_length_num_iter

                    % Run dark carrier simulation for green comparison
                    if (L == 100) && (bulk_doping == 1E16) && (p0 == bulk_doping * 100) && (n0 == bulk_doping * 100) && (taup == 10) && (taun == 10) && (mup == 500) && (mun == 1450)
                        run_study_2 = 1;
                    elseif (L == 140) && (bulk_doping == 1E14) && (p0 == bulk_doping * 10000) && (n0 == bulk_doping * 10000) && (taup == 100) && (taun == 100) && (mup == 1077) && (mun == 3124)
                        run_study_2 = 1;
                    elseif (L == 220) && (bulk_doping == 1E15) && (p0 == bulk_doping * 10) && (n0 == bulk_doping * 10) && (taup == 1) && (taun == 1) && (mup == 387) && (mun == 1123)
                        run_study_2 = 1;
                    else
                        run_study_2 = 0;
                    end

                    % Prepare simulation parameters
                    n_junction_loc = L - junction_loc_n;
                    size_of_mesh_element = L / number_of_intervals_in_mesh;
                    delta_list = generate_delta_locations(size_of_mesh_element, number_of_intervals_in_mesh);
                    number_of_deltas = height(delta_list);
                    loc0 = delta_list{:,2};

                    % save delta_list
                    writetable(delta_list,strcat(base_directory,'outside_parameters\delta_list.csv'),'WriteVariableNames',false);

                    % Display parameter values
                    X = sprintf('Bulk: %d p0: %d n0: %d taup: %d taun: %d mup: %d mun: %d L: %d', ... 
                                bulk_doping, p0, n0, taup, taun, mup, mun, L);
                    disp(X) 

                    % Comsol model calculation
                    comsol_create_model; 
                    % Calculating resulting IQE and SCE from Comsol run
                    get_results_from_model;
                    % For specific devices, compare to Green analytical
                    % model
                    if (L == 100) && (bulk_doping == 1E16) && (p0 == bulk_doping * 100) && (n0 == bulk_doping * 100) && (taup == 10) && (taun == 10) && (mup == 500) && (mun == 1450)
                        Sp = 50;    % Surface recombination velocity (p-side)
                        Sn = 220;   % Surface recombination velocity (n-side)
                        Green_comparison;
                    elseif (L == 140) && (bulk_doping == 1E14) && (p0 == bulk_doping * 10000) && (n0 == bulk_doping * 10000) && (taup == 100) && (taun == 100) && (mup == 1077) && (mun == 3124)
                        Sp = 1;     % Surface recombination velocity (p-side)
                        Sn = 5;     % Surface recombination velocity (n-side)
                        Green_comparison;
                    elseif (L == 220) && (bulk_doping == 1E15) && (p0 == bulk_doping * 10) && (n0 == bulk_doping * 10) && (taup == 1) && (taun == 1) && (mup == 387) && (mun == 1123)
                        Sp = 100;   % Surface recombination velocity (p-side)
                        Sn = 1000;  % Surface recombination velocity (n-side)
                        Green_comparison;
                    end
                    % Prepare data for ML consumption
                    create_labels_matrix;
                    % Evaluate IQE based on analytical model
                    evaluate_database;

                    % Record end time and save results  
                    t2 = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
                    disp(t2); 

                    filename = strcat(base_directory,'results_SCE\',sprintf('SCE_bulk_doping_%0.e_p0_%0.e_n0_%0.e_taup_%d_taun_%d_mup_%d_mun_%d_L_%d.csv',bulk_doping,p0,n0,taup,taun,mup,mun,L));
                    writematrix(SCE_comsol,filename);

                    filename = strcat(base_directory,'results_IQE\',sprintf('IQE_bulk_doping_%0.e_p0_%0.e_n0_%0.e_taup_%d_taun_%d_mup_%d_mun_%d_L_%d.csv',bulk_doping,p0,n0,taup,taun,mup,mun,L));
                    writematrix(IQE,filename)

                    filename = strcat(base_directory,'results_LAB\',sprintf('LAB_bulk_doping_%0.e_p0_%0.e_n0_%0.e_taup_%d_taun_%d_mup_%d_mun_%d_L_%d.csv',bulk_doping,p0,n0,taup,taun,mup,mun,L));
                    writematrix(label_mat,filename)

                    % Update parameters for the next iteration 
                    %calculate device length         
                    L = L + device_length_jump;
                end
                %calculate mobility
                mup = mup * mup_jump;
                mun = mun * mun_jump;
                L = L_first;
            end
            %calculate lifetime
            taup = taup * taup_jump;
            taun = taun * taun_jump;
            mup = mup_first;
            mun = mun_first;
        end
        %calculate junction concentration
        p0 = p0 * p0_jump;
        n0 = n0 * p0_jump;
        taup = taup_first;
        taun = taun_first;
    end
    %calculate next bulk concentration
    bulk_doping = bulk_doping * bulk_doping_jump;
    p0_first = bulk_doping * 10;
    n0_first = bulk_doping * 10;
    p0_jump = 10^((log10(p0_last/p0_first))/(junction_doping_num_iter-1));
    n0_jump = 10^((log10(n0_last/n0_first))/(junction_doping_num_iter-1));
end