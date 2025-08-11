clear;

% Parameters
fs = 1000;  % Sampling frequency (Hz)
n_channels = 32;
range = [31 45];  % Gamma band range (Hz)
n_seconds = 2400;
window_duration = 104;
n_subjects = 1;

for subj = 1:n_subjects

    filename = sprintf('EEG_Subject_%02d_32ch.mat', subj);
    data = load(filename, 'EEG_Nback','standard_32');

    channel_labels = data.standard_32;

    eeg_data = data.EEG_Nback';  % [samples x channels]

    figure('Name', ['Subject ', num2str(subj)], 'NumberTitle', 'off');
    set(gcf, 'DefaultAxesFontName', 'Arial');

    for ch = 1:n_channels
        eeg_ch = eeg_data(:, ch);
        gamma_power = zeros(n_seconds, 1);

        for sec = 1:n_seconds
            segment = eeg_ch((sec-1)*fs+1:sec*fs);
            gamma_power(sec) = bandpower(segment, fs, range);
        end

        gamma_power = mat2gray(gamma_power);

        window_size = window_duration;
        n_windows = floor(n_seconds / window_size);
        p_values = zeros(n_windows - 1, 1);
        significant_change = false;
        first_significant_change = nan;

        for w = 1:n_windows-1
            window1 = gamma_power((w-1)*window_size+1 : w*window_size);
            window2 = gamma_power(w*window_size+1 : (w+1)*window_size);
            [~, p_values(w)] = ttest2(window1, window2);
            if p_values(w) < 0.005 && ~significant_change
                first_significant_change = w * window_size;
                significant_change = true;
            end
        end

        subplot(4, 8, ch);
        hold on;
        time_minutes = (1:n_seconds) / 60;
        plot(time_minutes, gamma_power, 'b');

        % Inverted bathtub hybrid curve
        x_vals = 1:n_seconds;
        transition_point = round(n_seconds * 0.6);
        slope = 0.015;
        sigmoid_rise = 1 ./ (1 + exp(-slope * (x_vals(1:transition_point) - transition_point/2)));
        sigmoid_rise = sigmoid_rise / max(sigmoid_rise);
        x_fall = x_vals(transition_point+1:end);
        fall_length = length(x_fall);
        quad_fall = -((1:fall_length) / fall_length).^2 + 1;
        quad_fall = max(sigmoid_rise) * quad_fall;
        hybrid_curve = [sigmoid_rise, quad_fall];
        hybrid_curve = max(gamma_power * 0.7) * hybrid_curve;
        smoothed_hybrid = smoothdata(hybrid_curve, 'movmean', 5);
        plot(time_minutes, smoothed_hybrid, 'r-', 'LineWidth', 1.5);

        if significant_change
            x_start = first_significant_change / 60;
            x_end = time_minutes(end);
            y_limits = ylim;

            fill([x_start x_end x_end x_start], ...
                 [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
                 [0.9 0.9 0.9], 'EdgeColor', 'none');

            uistack(findall(gca, 'Type', 'line'), 'top');

            xline(x_start, 'r--', 'LineWidth', 1.5);
            x_opt = (first_significant_change + 455) / 60;
            xline(x_opt, 'k--', 'LineWidth', 1.5);

            text(x_start/2, y_limits(2)*0.95, 'I', ...
                'Color', 'r', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
            text((x_start + x_end)/2, y_limits(2)*0.95, 'II', ...
                'Color', 'r', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        end

        title(channel_labels{ch}, 'FontWeight', 'normal', 'FontName', 'Arial');
        set(gca, 'FontSize', 13, 'FontName', 'Arial', 'LineWidth', 1.5);
        hold off;
    end

    han = axes(gcf, 'visible', 'off');
    han.XLabel.Visible = 'on';
    han.YLabel.Visible = 'on';
    xlabel(han, 'Time (minutes)', 'FontSize', 16, 'FontName', 'Arial');
    ylabel(han, 'Normalized Gamma Band Power', 'FontSize', 16, 'FontName', 'Arial');
end
