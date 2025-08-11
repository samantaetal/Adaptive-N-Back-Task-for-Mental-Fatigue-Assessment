clear; close all;

fs = 1000;                      % Sampling rate
gamma_range = [30 45];          % Gamma band (Hz)
window_duration = 104;          % T-test window duration in seconds
n_subjects = 10;                % Number of subjects
n_channels = 32;

load('C:\Users\B00896414\OneDrive - Ulster University\Phd Related Papers and Data\N-back\Optimal_Time_delay.mat')

for subj = 1:n_subjects
    fprintf('Processing Subject %02d...\n', subj);

    intermediate_duration = Optimal_deltaT(subj) * 60;

    % Load EEG data
    filename = sprintf('EEG_Subject_%02d_32ch.mat', subj);
    load(filename, 'EEG_Nback');  % Variable shape: [channels x samples]

    [n_channels, n_samples] = size(EEG_Nback);
    n_seconds = floor(n_samples / fs);
    
    % Compute gamma power time series (per second, per channel)
    gamma_power = zeros(n_channels, n_seconds);
    for ch = 1:n_channels
        for sec = 1:n_seconds
            segment = EEG_Nback(ch, (sec-1)*fs+1 : sec*fs);
            gamma_power(ch, sec) = bandpower(segment, fs, gamma_range);
        end
    end
    
    % Average gamma across channels
    avg_gamma = mean(gamma_power, 1);

    % Find first significant change in gamma power using t-test
    n_windows = floor(n_seconds / window_duration);
    first_sig_change_sample = 0;
    found = false;

    for w = 1:n_windows - 1
        win1 = avg_gamma((w-1)*window_duration+1 : w*window_duration);
        win2 = avg_gamma(w*window_duration+1 : (w+1)*window_duration);
        [~, p] = ttest2(win1, win2);
        if p < 0.005 && ~found
            first_sig_change_sample = w * window_duration * fs;
            found = true;
        end
    end

    if ~found
        warning('No significant change found for Subject %02d. Skipping...', subj);
        continue;
    end

    inter_start = first_sig_change_sample + 1;
    inter_end = inter_start + intermediate_duration * fs - 1;

    if inter_end >= n_samples
        warning('Not enough data for intermediate and fatigue segments. Skipping Subject %02d.', subj);
        continue;
    end

    % Define data segments
    eeg_nonfatigue = EEG_Nback(:, 1:first_sig_change_sample);
    eeg_intermediate = EEG_Nback(:, inter_start:inter_end);
    eeg_fatigue = EEG_Nback(:, inter_end+1:end);

    % Initialize coherence matrices
    coh_nonfatigue = zeros(n_channels, n_channels);
    coh_intermediate = zeros(n_channels, n_channels);
    coh_fatigue = zeros(n_channels, n_channels);

    % Compute average coherence across gamma band
    for i = 1:n_channels
        for j = i+1:n_channels            
            % Non-fatigue
            [cxy_nf, f_nf] = mscohere(eeg_nonfatigue(i,:), eeg_nonfatigue(j,:), [], [], [], fs);
            gamma_idx_nf = f_nf >= gamma_range(1) & f_nf <= gamma_range(2);
            val_nf = mean(cxy_nf(gamma_idx_nf));
            coh_nonfatigue(i,j) = val_nf;
            coh_nonfatigue(j,i) = val_nf;

            % Intermediate
            [cxy_im, f_im] = mscohere(eeg_intermediate(i,:), eeg_intermediate(j,:), [], [], [], fs);
            gamma_idx_im = f_im >= gamma_range(1) & f_im <= gamma_range(2);
            val_im = mean(cxy_im(gamma_idx_im));
            coh_intermediate(i,j) = val_im;
            coh_intermediate(j,i) = val_im;

            % Fatigue
            [cxy_f, f_f] = mscohere(eeg_fatigue(i,:), eeg_fatigue(j,:), [], [], [], fs);
            gamma_idx_f = f_f >= gamma_range(1) & f_f <= gamma_range(2);
            val_f = mean(cxy_f(gamma_idx_f));
            coh_fatigue(i,j) = val_f;
            coh_fatigue(j,i) = val_f;
        end
    end

    % Save results
    save(sprintf('Adjacency_CoherenceAvgGamma_Subject_%02d.mat', subj), ...
        'coh_nonfatigue', 'coh_fatigue', 'coh_intermediate');
end
