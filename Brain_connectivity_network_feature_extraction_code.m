clear; close all;

n_subjects = 1;

% Initialize structures
fatigue = struct('clustering_coeff', zeros(n_subjects,1), ...
                 'modularity', zeros(n_subjects,1), ...
                 'eigenvector_centrality', zeros(n_subjects,1), ... 
                 'participation_coeff', zeros(n_subjects,1));       

non_fatigue = fatigue;

channels = {'Fp1','Fpz','Fp2','AF3','AF4','F7','F3','Fz','F4','F8','FC5','FC1','FCz','FC2','FC6', ...
            'T7','C3','Cz','C4','T8','CP5','CP1','CPz','CP2','CP6','P7','P3','Pz','P4','P8','POz','Oz'};

for subj = 1:n_subjects
    fname = sprintf('Adjacency_CoherenceAvgGamma_Subject_%02d.mat', subj);
    data = load(fname);
    
    for k = 1:3
        if k == 1
            A = data.coh_nonfatigue;
            dest = 'non_fatigue';
        elseif k == 2
            A = data.coh_intermediate;
            dest = 'inter_fatigue';
        else
            A = data.coh_fatigue;
            dest = 'fatigue';
        end

        A = A - diag(diag(A));

        % Network metrics
        C = clustering_coef_wu(A);
        clustering_coeff = mean(C);

        [Ci, modularity] = modularity_und(A);

        ec = eigenvector_centrality_und(A);
        eigenvector_centrality = mean(ec);

        pc = participation_coef(A, Ci);
        participation_coeff = mean(pc(~isnan(pc)));

        % Save into correct structure
        eval(sprintf('%s.clustering_coeff(subj) = clustering_coeff;', dest));
        eval(sprintf('%s.modularity(subj) = modularity;', dest));
        eval(sprintf('%s.eigenvector_centrality(subj) = eigenvector_centrality;', dest));
        eval(sprintf('%s.participation_coeff(subj) = participation_coeff;', dest));
    end
end

% Save all features (Extracted features from all subjects are available in the google drive link)
save('Network_Measures.mat', 'fatigue', 'non_fatigue');
