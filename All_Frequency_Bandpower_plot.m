clear; close all;

% Parameters
fs = 1000;  % Sampling frequency (Hz)
n_channels = 32;  % Number of EEG channels
n_seconds = 2400;  % Total duration in seconds (40 minutes)

% Frequency bands
bands = {
    'Delta', [1 3];
    'Theta', [4 7];
    'Alpha', [8 13];
    'Beta', [14 30];
    'Gamma', [31 45];
};
n_bands = size(bands, 1);

% Time points to plot (in minutes)
selected_minutes = [1, 10, 20, 30, 40];
time_labels = ["1", "10", "20", "30", "40"];

% Custom colors: delta = green, gamma = blue
colors = lines(n_bands);
colors(1,:) = [0, 0.6, 0];  % Delta - green
colors(5,:) = [0, 0, 1];    % Gamma - blue

% Load EEG and fatigue data
load('EEG_Subject_01_32ch.mat')

% Channel names
channel_names = standard_32;

eeg_data = EEG_Nback';  % [samples x channels]

% ----- FIGURE 1: Per-channel Band Power Trends -----
fig1 = figure('Units', 'normalized', 'Position', [0.02 0.1 0.96 0.82]);
t1 = tiledlayout(fig1, 4, 8, 'TileSpacing', 'loose', 'Padding', 'compact');

% Storage for summary plots
r_squared_all = zeros(n_channels, n_bands);
dist_at_18_all = zeros(n_channels, n_bands);

n_minutes = floor(n_seconds / 60);

for ch = 1:n_channels
    eeg_ch = eeg_data(:, ch);
    band_power_minute_avg = zeros(n_minutes, n_bands);

    for sec = 1:n_seconds
        segment = eeg_ch((sec-1)*fs + 1 : sec*fs);
        m = ceil(sec / 60);
        for b = 1:n_bands
            band_power_minute_avg(m, b) = band_power_minute_avg(m, b) + bandpower(segment, fs, bands{b, 2});
        end
    end
    band_power_minute_avg = band_power_minute_avg / 60;

    selected_vals = band_power_minute_avg(selected_minutes, :);

    % Normalize
    norm_vals = zeros(size(selected_vals));
    for b = 1:n_bands
        col = selected_vals(:, b);
        min_val = min(col);
        max_val = max(col);
        if max_val - min_val > 0
            norm_vals(:, b) = 0.1 + 0.9 * (col - min_val) / (max_val - min_val);
        else
            norm_vals(:, b) = ones(size(col));
        end
    end

    nexttile(t1, ch)
    hold on;
    group_width = min(0.8, n_bands/(n_bands+1.5));
    for b = 1:n_bands
        x = (1:size(norm_vals, 1)) - group_width/2 + (2*b-1) * group_width / (2*n_bands);
        bar(x, norm_vals(:, b), group_width / n_bands, 'FaceColor', colors(b,:), 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    end

    x18_pos = interp1(selected_minutes, 1:length(selected_minutes), 18, 'linear', 'extrap');
    xline(x18_pos, '--k', 'LineWidth', 1.2);

    fine_time = linspace(1, size(norm_vals, 1), 200);
    for b = 1:n_bands
        p = polyfit(1:size(norm_vals, 1), norm_vals(:, b)', 2);
        trend = polyval(p, fine_time);
        plot(fine_time, trend, '-', 'Color', colors(b,:), 'LineWidth', 1.5);
    end

    xticks(1:length(time_labels));
    xticklabels(time_labels);
    ylim([0 1.1]);
    title(channel_names{ch}, 'FontWeight', 'normal', 'FontName', 'Arial');
    set(gca, 'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'normal', 'LineWidth', 1.5);
    box off;
    hold off;

    % Compute R² and peak distance
    x = 1:size(norm_vals, 1);
    for b = 1:n_bands
        y = norm_vals(:, b)';
        p = polyfit(x, y, 2);
        y_fit = polyval(p, x);

        % R-squared
        SS_res = sum((y - y_fit).^2);
        SS_tot = sum((y - mean(y)).^2);
        r_squared_all(ch, b) = 1 - SS_res / SS_tot;

        % Find peak of the fitted curve
        if p(1) > 0
            [~, peak_idx] = min(y_fit);  % upward parabola (min)
        else
            [~, peak_idx] = max(y_fit);  % downward parabola (max)
        end
        x_peak = x(peak_idx);
        time_peak = interp1(x, selected_minutes, x_peak);

        % Time difference from 18 minutes
        dist_at_18_all(ch, b) = abs(time_peak - 18);
    end
end

% Compute mean and std for summary plots
mean_r2 = mean(r_squared_all);
std_r2 = std(r_squared_all);
mean_dist = mean(dist_at_18_all);
std_dist = std(dist_at_18_all);

% Add common x and y labels to Figure 1
xlabel(t1, 'Time (minutes)', 'FontSize', 14, 'FontWeight', 'normal', 'FontName', 'Arial');
ylabel(t1, 'Normalized Band Power', 'FontSize', 14, 'FontWeight', 'normal', 'FontName', 'Arial');


% ----- FIGURE 2: Summary Statistics -----
fig2 = figure('Units', 'normalized', 'Position', [0.2 0.2 0.6 0.5]);
t2 = tiledlayout(fig2, 1, 2, 'TileSpacing', 'loose', 'Padding', 'compact');

% --- R² Summary Plot ---
nexttile(t2, 1)
h = bar(1:n_bands, mean_r2, 'FaceColor', 'flat','FaceAlpha',0.55);
h.CData = colors(1:n_bands, :);
hold on;
errorbar(1:n_bands, mean_r2, std_r2, '.k', 'LineWidth', 1.2, 'CapSize', 10);
set(gca, 'XTick', 1:n_bands, 'XTickLabel', bands(:,1), 'FontSize', 12, 'FontName', 'Arial', 'LineWidth', 1.5, 'FontWeight', 'normal');
ylabel('R^2 Value', 'FontName', 'Arial', 'FontWeight', 'normal');
ylim([0 1]);
box off;

% --- Distance Plot ---
nexttile(t2, 2)
h = bar(1:n_bands, mean_dist, 'FaceColor', 'flat','FaceAlpha',0.55);
h.CData = colors(1:n_bands, :);
hold on;
errorbar(1:n_bands, mean_dist, std_dist, '.k', 'LineWidth', 1.2, 'CapSize', 10);
set(gca, 'XTick', 1:n_bands, 'XTickLabel', bands(:,1), 'FontSize', 12, 'FontName', 'Arial', 'LineWidth', 1.5, 'FontWeight', 'normal');
ylabel('Time Delay (minutes)', 'FontName', 'Arial', 'FontWeight', 'normal');
ylim([0, max(mean_dist + std_dist) + 0.05]);
box off;
