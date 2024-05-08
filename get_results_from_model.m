% Extract Lambda0 values from the COMSOL solution 
Lambda0_arr = mphglobal(model, 'Lambda0');
Lambda0_struct = mpheval(model, 'Lambda0', 'dataset', 'dset3');
Lambda0 = Lambda0_struct.d1(1); % Assuming the desired value is the first element
clear Lambda0_struct;

% Calculate IQE from the simulation data
IQE_struct = mpheval(model, 'semi.I0_2/(q*PHY *A * (1-R))', 'unit', '1', 'dataset', 'dset1');
IQE(:,1) = Lambda0_arr(:,1);  % Store Lambda0 values
IQE(:,2) = IQE_struct.d1(:,1); % Store IQE values
IQE(1,3) = L;
clear IQE_struct;

% Extract IQE value corresponding to Lambda0
logicalMapOfLocations = IQE(:,1) == Lambda0;
index_of_lamda0 = find(logicalMapOfLocations); % Find the index
IQE_spec = IQE(index_of_lamda0,2);

% Parameters for Gaussian distribution of generation profile
Ld = L * 1E-6;  % Convert device length to meters
% delta_amplitude_b defined in generate_database.m
% sigma defined in generate_database.m

% Define symbolic variable and generation function (requires Symbolic Math Toolbox)
syms x;
fun_delta_G = (delta_amplitude_b .* (1./((sigma.*1E-9) .*sqrt(2 .* pi) )).*exp(-0.5 .* (((x-(loc0.*1E-6))/(sigma.*1E-9)).^2)));

% Calculate generated charge due to delta function
generated_by_delta = q * int(fun_delta_G,x,0,Ld); 

% Fetch SCE data from the simulation
SCE_struct_a = mpheval(model, 'semi.I0_2/A', 'unit', 'A/m^2', 'dataset', 'dset3');
SCE_struct_b = mpheval(model, 'q * integrate(G_tot,x,0,L)', 'unit', 'A/m^2', 'dataset', 'dset3');

% Calculate SCE and store it in an array
SCE_comsol(:,1) = loc0(:,1); 
SCE_comsol(:,2) = (SCE_struct_a.d1(:,1) - (SCE_struct_b.d1(:,1).*IQE_spec))./generated_by_delta(2); 
clear SCE_struct_a; clear SCE_struct_b;

% Ensure SCE values are within the range of 0 and 1
SCE_comsol(:,2) = min(SCE_comsol(:,2), 1);
SCE_comsol(:,2) = max(SCE_comsol(:,2), 1e-4); 
