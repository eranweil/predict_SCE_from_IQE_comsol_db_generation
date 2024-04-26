% Evaluating Data from simulation
% Fetch generation rate (per wavelength and location) from COMSOL model
G_tot_struct = mpheval(model, 'G_tot', 'dataset', 'dset1', 'unit', '1/(cm^3*s)');
G_tot_values_per_lambda = G_tot_struct.d1;  
G_tot_mesh_loc = G_tot_struct.p; 
clear G_tot_struct; % Free up memory 

% Fetch recombination data from COMSOL model
R_struct = mpheval(model, 'R', 'dataset', 'dset1');
R_values_per_lambda = R_struct.d1; 
clear R_struct;  % Free up memory

% Extract device-related constant from COMSOL model
PHY = mphglobal(model, 'PHY');

% NaN Handling
% Adjust a value in loc0 (to avoid NaN issues)
loc0(40) = loc0(40) - 0.00001; 

% Adjust a column in G_tot_mesh_loc (to avoid NaN issues)
G_tot_mesh_loc(:, 2401) = G_tot_mesh_loc(:, 2401) - 0.00001; 

% Integral Calculation 
% Define grids for generation rate and SCE locations
x_G = G_tot_mesh_loc; 
x_SCE = loc0; 

% Initialize matrix to store integrating generation values
integrals = zeros(size(G_tot_values_per_lambda, 1), size(x_SCE, 1) - 1);

% Calculate integration matrix of generation rate
for i = 1:size(G_tot_values_per_lambda, 1)  % Loop over wavelengths
    R = mphglobal(model, 'R'); % Fetch recombination data (might need refinement)

    for j = 1:size(x_SCE, 1) - 1  % Loop over SCE intervals
        % Find indices corresponding to current SCE interval 
        indices = find(loc0(j) <= linspace(0, L, length(x_G)) & ...
                       linspace(0, L, length(x_G)) <= loc0(j + 1));

        % Integrate generation rate over the interval
        integral_value = trapz(x_G(indices), G_tot_values_per_lambda(i, indices));

        % Store normalized integrated generation
        integrals(i, j) = integral_value / (1 - R_values_per_lambda(i, 1)); 
    end
end

% SCE Averaging 
SCE_comsol_values = SCE_comsol(:, 2); % Extract SCE values
SCE_comsol_average = (SCE_comsol_values(1:end-1) + SCE_comsol_values(2:end)) / 2;

% IQE Calculation from COMSOL SCE
IQE_vector_sol1 = (integrals * SCE_comsol_average) / PHY(1); 

% % Plot the IQE matrix
% plot(IQE(:, 1), IQE(:, 2), 'o-'); % Plot as individual points connected by lines
% xlabel('Wavelength (um)');
% ylabel('IQE');
% title('IQE from COMSOL Simulation');
% % Hold the plot for overlaying
% hold on; 
% % Plot IQE_vector_sol1 
% plot(IQE(:, 1), IQE_vector_sol1, 'r-'); % Plot as a red line
% legend('IQE Data', 'IQE Calculated from SCE');
% % Release the hold
% hold off; 

% Validation
IQE_difference = IQE_vector_sol1(11:31) - IQE(11:31,2);
if max(abs(IQE_difference)) > 0.1
    % Handle validation failure if needed
    disp(strcat('Validation failed for current parameter set: ',sprintf(' IQE_bulk_doping %0.e, p0 %0.e, n0 %0.e, taup %d, taun %d, mup %d, mun %d, L %d',bulk_doping,p0,n0,taup,taun,mup,mun,L)));
    disp(strcat('IQE file saved to directory: ',base_directory,'untolerated_devices\'));
    output_untolerated_device_filename = strcat(base_directory,'untolerated_devices\',sprintf('IQE_bulk_doping_%0.e_p0_%0.e_n0_%0.e_taup_%d_taun_%d_mup_%d_mun_%d_L_%d.csv',bulk_doping,p0,n0,taup,taun,mup,mun,L));
    writematrix(IQE,output_untolerated_device_filename)
else
    disp('Validation successful');
end
