function generate_delta_locations = generate_delta_locations(size_of_mesh_element, number_of_intervals_in_mesh)
% This function generates locations within a mesh where 'delta-like' features
% should be placed. The spacing of these locations varies across the mesh.

% Define sections with different spacing rules:
section_0 = 10;  % Spacing every 2nd element near edges
section_1 = 25;  % Spacing every 5th element
section_2 = 50;
section_3 = 100;
section_4 = 200;

% Initialize variables:
num_points = number_of_intervals_in_mesh + 1; 
j = 0; % Counter for generated locations 
col1 = zeros(num_points,1); % Column for indices of generated locations 
col2 = zeros(num_points,1); % Column for physical positions

% Iterate through the mesh:
for i = 1:num_points   
    % Rule for edges:
    if (i-1 < section_0) || (i-1 > number_of_intervals_in_mesh - section_0)
        if mod(i-1, 2) == 0  % Place a location every 2nd element
            j = j + 1;
            col1(j) = j; 
            col2(j) = (i-1) * size_of_mesh_element;
        end
    
    % Rule for section 1:
    elseif (i-1 < section_1) || (i-1 > number_of_intervals_in_mesh - section_1)
        if mod(i-1, 5) == 0 % Place a location every 5th element
            j = j + 1;
            col1(j) = j; 
            col2(j) = (i-1) * size_of_mesh_element;
        end

    % Rule for section 2:
    elseif (i-1 < section_2) || (i-1 > number_of_intervals_in_mesh - section_2)
        if mod(i-1, 10) == 0 % Place a location every 10th element
            j = j + 1;
            col1(j) = j; 
            col2(j) = (i-1) * size_of_mesh_element;
        end    

    % Rule for section 3:
    elseif (i-1 < section_3) || (i-1 > number_of_intervals_in_mesh - section_3)
        if mod(i-1, 20) == 0 % Place a location every 20th element
            j = j + 1;
            col1(j) = j; 
            col2(j) = (i-1) * size_of_mesh_element;
        end  

    % Rule for section 4:
    elseif (i-1 < section_4) || (i-1 > number_of_intervals_in_mesh - section_4)
        if mod(i-1, 40) == 0 % Place a location every 40th element
            j = j + 1;
            col1(j) = j; 
            col2(j) = (i-1) * size_of_mesh_element;
        end   
    % Rule for the central region:
    else 
        if mod(i-1, 160) == 0  % Place a location every 160th element
            j = j + 1;
            col1(j) = j; 
            col2(j) = (i-1) * size_of_mesh_element;
        end
    end
end

% Create an output table:
generate_delta_locations = table(col1(1:j), col2(1:j)); 
end
