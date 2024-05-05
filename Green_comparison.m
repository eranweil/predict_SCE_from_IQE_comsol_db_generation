% Semiconductor Device Spatial Collection Efficiency (SCE) Modeling and Comparison

% Parameter Extraction from Simulation
% Hole diffusion coefficient
Dp_struct = mpheval(model,'comp1.semi.Dp','unit','m^2/s','dataset','dset4');
Dp = Dp_struct.d1(1,1); clear Dp_struct;

% Electron diffusion coefficient
Dn_struct = mpheval(model,'comp1.semi.Dn','unit','m^2/s','dataset','dset4');
Dn = Dn_struct.d1(1,1); clear Dn_struct;

% Minority carrier diffusion length (p-side)
Ln = sqrt(Dp * taup * 1e-6);

% Minority carrier diffusion length (n-side)
Lp = sqrt(Dn * taun * 1e-6);

% N+ junction depth
nn_junc_loc_struct = mpheval(model,'nn_junction_depth','unit','m','dataset','dset4');
nn_junc_loc = nn_junc_loc_struct.d1(1,1); clear nn_junc_loc_struct;

% PN junction depth
pn_junc_loc_struct = mpheval(model,'pn_junction_depth','unit','m','dataset','dset4');
pn_junc_loc = pn_junc_loc_struct.d1(1); clear pn_junc_loc_struct;

% Additional Parameters and Scaling
wpplus = pn_junc_loc;           % Edge of depletion region on p-side
wnplus = nn_junc_loc;           % Edge of depletion region on n-side
wn = Ld - wpplus - wnplus;      % Neutral region width on n-side

% Calculation of Scaling Factors
Kp = (1 + (Sp*Lp/Dp)) / (1 - (Sp*Lp/Dp));  
Kn = (1 + (Sn*Ln/Dn)) / (1 - (Sn*Ln/Dn));

% Scaling of Reference Data for Comparison
SCE_Green = [SCE_comsol(:,1) * 1e-6, SCE_comsol(:,2)];   % Scale down x-values to meters
Green_points = SCE_Green(:,1);                           % Extract scaled x-values

% Definition of Spatial Collection Efficiency (SCE) Functions
fun_SCE_pplus = @(z) (Kp*exp(z/Lp)+exp(-z/Lp))/(Kp*exp(wpplus/Lp)+exp(-wpplus/Lp)); % p+ region SCE
fun_SCE_n = @(z) (Kn*exp((Ld-z)/Ln)+exp(-(Ld-z)/Ln))/(Kn*exp(wn/Ln)+exp(-wn/Ln));   % n  region SCE

% High-Resolution Calculation and Sampling
z = linspace(0, Ld, 1000);         % Fine-grained position array
y = zeros(size(z));                % Initialize SCE array

% Calculate SCE based on region
y(z < wpplus) = fun_SCE_pplus(z(z < wpplus));
y(z >= wpplus & z <Ld - wnplus) = fun_SCE_n(z(z >= wpplus & z < Ld - wnplus));
y(z >= Ld - wnplus) = fun_SCE_n(Ld - wnplus);

% Visualization
figure;
hold on;
plot(Green_points, SCE_Green(:,2), 'o', 'MarkerSize', 6, 'DisplayName', 'SCE_Comsol'); % Generated SCE from comsol model
plot(z, y, '-', 'LineWidth', 1.5, 'DisplayName', 'SCE_Green');                         % Calculated SCE from Green

hold off;
xlabel('Position (m)');
ylabel('Spatial Collection Efficiency');  % Changed to SCE
title('SCE Comparison: Green Data vs. Model');
legend('Location', 'Best');
grid on;
