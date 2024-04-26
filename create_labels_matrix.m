% Data Preparation 
% Assuming SCE_comsol is a matrix containing SCE data (column 1: x-values, column 2: SCE values) 
% L is likely the total length or extent represented by the x-values.

% Finding Key Points
[SCE_max, SCE_max_point_index] = max(SCE_comsol(1:20,2));  % Find max SCE value and its index within the first 20 points
SCE_max_point = SCE_comsol(SCE_max_point_index,1);      % Corresponding x-value 
slope = diff(SCE_comsol(:,2)) ./ diff(SCE_comsol(:,1));  % Calculate slope of SCE curve
SCE_drop_point_index = 20 + find_index_of_SCE_drop(slope(20:end));  % Find index of significant SCE drop
SCE_drop_point = SCE_comsol(SCE_drop_point_index,1);   % Corresponding x-value

% Section-wise Polynomial Fitting
% Section 1: Beginning of the graph
xx_fit1_section = 0:SCE_max_point/8:SCE_max_point;      % Evenly spaced x-values for fitting  
yy_fit1_section = interp1(SCE_comsol(1:SCE_max_point_index, 1), ...  % Interpolate SCE values 
                          SCE_comsol(1:SCE_max_point_index, 2), ... 
                          xx_fit1_section, 'linear'); 
fit_result1 = fit(xx_fit1_section', yy_fit1_section', 'poly8');  % 8th-degree polynomial fit

% Section 2: Middle of the graph
xx_fit2_section = SCE_max_point:(SCE_drop_point - SCE_max_point)/8:SCE_drop_point; 
yy_fit2_section = interp1(SCE_comsol(SCE_max_point_index:SCE_drop_point_index, 1), ...
                          SCE_comsol(SCE_max_point_index:SCE_drop_point_index, 2), ... 
                          xx_fit2_section, 'linear');
fit_result2 = fit(xx_fit2_section', yy_fit2_section', 'poly8');

% Section 3: End of the graph
xx_fit3_section = SCE_drop_point:(L-SCE_drop_point)/8:L;
yy_fit3_section = interp1(SCE_comsol(SCE_drop_point_index:end, 1), ...
                          SCE_comsol(SCE_drop_point_index:end, 2), ...
                          xx_fit3_section, 'linear');
fit_result3 = fit(xx_fit3_section', yy_fit3_section', 'poly4');  % Lower-degree polynomial for the tail

% Plotting (Commented out)
% plot(SCE_comsol(:,1), SCE_comsol(:,2),'o', ...
%    SCE_comsol(1:SCE_max_point_index,1),fit_result1(SCE_comsol(1:SCE_max_point_index,1)),'r', ...
%    SCE_comsol(SCE_max_point_index:SCE_drop_point_index,1),fit_result2(SCE_comsol(SCE_max_point_index:SCE_drop_point_index,1)),'r', ...
%    SCE_comsol(SCE_drop_point_index:end,1),fit_result3(SCE_comsol(SCE_drop_point_index:end,1)),'r')

% Storing Key Results
labels = [SCE_max_point, SCE_drop_point, coeffvalues(fit_result1), coeffvalues(fit_result2), coeffvalues(fit_result3)];
label_mat = [vector_25', labels']; 
