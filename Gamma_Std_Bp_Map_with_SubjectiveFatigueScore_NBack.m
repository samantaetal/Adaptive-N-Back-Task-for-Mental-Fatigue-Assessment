clear; close all;

n_subjects = 1;

% Define colors for different N-back values
cmap = [0, 0.5, 0; 0, 0, 1; 1, 1, 0; 1, 0, 0]; % Colormap for N-back values

for sub = 1:n_subjects

    % Load data
    load(sprintf('Subject_%02d_N_WL.mat', sub))
    load(sprintf('Subject_%02d_Std_IntraTask_Gamma_Bp.mat', sub))
    load(sprintf('Subject_%02d_IntraTask_SubjectiveFatigueScore.mat', sub))
    
    N_values = N'; % N-back values
    subjective_scores = fatigue_score'; % Fatigue scores
    std_bp = Std_Bp'; % Standard deviation of band power
    num_points = length(N_values);
    
    % Normalize fatigue scores for vertical heatmap (range 0 to 1)
    norm_fatigue = (subjective_scores - min(subjective_scores)) / (max(subjective_scores) - min(subjective_scores));
    
    % Create a meshgrid for the heatmap
    [X, Y] = meshgrid(1:num_points, [min(std_bp), max(std_bp)]);
    
    % The Z data is the normalized fatigue scores, replicated for vertical extension
    Z = repmat(norm_fatigue, 2, 1);
    
    % Get unique N-back values
    unique_N = unique(N_values);
    
    % Combined plot in the first subplot (all N-back values together)
    num_subplots = length(unique_N) + 1; % Total subplots = number of unique N-back values + 1 for the combined plot
    
    % Set axis limits and other consistent parameters
    y_limits = [0, max(std_bp)+max(std_bp)*0.5]; % Keep the same y-axis limits for all subplots
    x_limits = [0, num_points+0.5]; % Keep the same x-axis limits for all subplots
    std_bp_max = max(std_bp); % Maximum y-axis for the stem plot
    
    % Combined plot in the first position of the row
    % subplot(1, num_subplots, 1);
    figure
    hold on;
    
    % Plot the full grayscale heatmap vertically
    imagesc(x_limits, y_limits, Z); % Full heatmap displayed
    
    % Adjust the colormap to grayscale and set the heatmap transparency
    colormap(sky);
    alpha(0.5); % Set transparency for the heatmap
    
    % Plot the stem plot with color-coded stems for each N-back value
    for i = 1:num_points
        stem(i, std_bp(i), 'Color', cmap(N_values(i)+1, :), 'LineWidth', 1);
    end
    
    % Set axis limits, labels, and other parameters for consistency
    xlim(x_limits);
    ylim(y_limits);
    % xlabel('Time (1.5 min epochs)');
    % ylabel('Std Band Power');
    grid on;
    hold off;
    ax = gca;
    ax.FontSize = 16; 
end
