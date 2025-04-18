%% Running TRF Analysis
clear
dataMainFolder = 'C:\Users\holly\OneDrive\Documents\MATLAB\Data analysis\HyperScanning\pilots';
dataCNDSubfolder = '\Pilot6\dataCND\';

tmin = -200;
tmax = 1000;
lambdas = [1e-8, 1e-6, 1e-4, 1e-2, 1e0, 1e2, 1e4, 1e6, 1e8];
dirTRF = 1;  % Forward TRF model

%eegFilenames = dir([dataMainFolder,dataCNDSubfolder,'pre1_SepdataSub*.mat']);
eegFilenames = dir(fullfile(dataMainFolder, dataCNDSubfolder, 'prebroadband100sr_pre1_SepdataSub*.mat'));
nSubs = length(eegFilenames);

% Create master figure for both stim 1 & 2
figure('Color', 'w', 'Position', [100, 100, 1300, 700]);
tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

% Loop over stimulus 1 & 2 (1 = Env, 2 = Env')
for stimidx = 1:2
    disp(['Processing Stimulus Index: ', num2str(stimidx)]);
    
    for sub = 1:nSubs
        % Load preprocessed EEG
        eegPreFilename = fullfile(eegFilenames(sub).folder, eegFilenames(sub).name);
        stimFilename = fullfile(eegFilenames(sub).folder, ['LallNorm_datastimSub', int2str(sub), '.mat']);

        disp(['Loading EEG: ', eegPreFilename]);
        load(eegPreFilename, 'eeg');
        eeg.fs = double(eeg.fs);

        disp(['Loading stimulus data: ', stimFilename]);
        load(stimFilename);
        
        stimFeature = stim;
        stimFeature.data = stimFeature.data(stimidx, :);  % Select feature based on index

        % Check matching length between EEG and stimulus
        if eeg.fs ~= stimFeature.fs
            disp('Error: EEG and STIM have different sampling frequencies.');
            return
        end
        if length(eeg.data) ~= length(stimFeature.data)
            disp('Error: EEG.data and STIM.data have different number of trials.');
            return
        end
        for tr = 1:length(stimFeature.data)
            minLen = min(size(stimFeature.data{tr}, 1), size(eeg.data{tr}, 1));
            stimFeature.data{tr} = double(stimFeature.data{tr}(1:minLen, :));
            eeg.data{tr} = double(eeg.data{tr}(1:minLen, :));
        end

        % Normalize EEG data
        clear tmpEeg;
        tmpEeg = eeg.data{1};
        for tr = 2:length(stimFeature.data)
            tmpEeg = cat(1, tmpEeg, eeg.data{tr});
        end
        normFactorEeg = std(tmpEeg(:));
        clear tmpEeg;
        for tr = 1:length(stimFeature.data)
            eeg.data{tr} = eeg.data{tr} / normFactorEeg;
        end

        featname = char(stimFeature.names{stimidx});
        disp(['Feature: ', featname]);

        % Run mTRF cross-validation
        disp('Running mTRFcrossval...');
        [stats, t] = mTRFcrossval(stimFeature.data, eeg.data, eeg.fs, dirTRF, tmin, tmax, lambdas, 'verbose', 0);
        [maxR, bestLambda] = max(squeeze(mean(mean(stats.r, 1), 3))); % Get best lambda
        disp(['Best Lambda: ', num2str(lambdas(bestLambda)), ' with r = ', num2str(maxR)]);

        rAll(sub) = maxR;
        statsAll(sub) = stats;
        best_lambda(sub) = lambdas(bestLambda);
        rAllElec(:, sub, stimidx) = squeeze(mean(stats.r(:, bestLambda, :), 1));

        % Train TRF model
        disp('Running mTRFtrain...');
        model = mTRFtrain(stimFeature.data, eeg.data, eeg.fs, dirTRF, tmin, tmax, lambdas(bestLambda), 'verbose', 0);
        modelAll(sub, stimidx) = model;
    end

    normFlag = 0;
    avgModel = mTRFmodelAvg(modelAll(:, stimidx), normFlag);

    %% Plotting 
    row = stimidx - 1;

    % Plot 1: TRF
    nexttile(row * 3 + 1);
    hold on;
    for sub = 1:nSubs
        plot(t, squeeze(modelAll(sub, stimidx).w(1, :, :)), 'LineWidth', 1);
    end
    title([char(stim.names{stimidx}), ' TRF'], 'FontSize', 22);
    xlabel('Time-latency (ms)', 'FontSize', 20);
    ylabel('Magnitude (a.u.)', 'FontSize', 20);
    xlim([tmin, tmax]);
    xticks(tmin:200:tmax);
    ylim padded
    grid on;
    set(gca, 'FontSize', 20);

    % Plot 2: GFP
    nexttile(row * 3 + 2);
    area(t, std(squeeze(modelAll(1, stimidx).w(1, :, :)), 0, 2), ...
        'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'none');
    title([char(stim.names{stimidx}), ' GFP'], 'FontSize', 22);
    xlabel('Time-latency (ms)', 'FontSize', 20);
    ylabel('Magnitude (a.u.)', 'FontSize', 20);
    xlim([tmin, tmax]);
    xticks(tmin:200:tmax);
    ylim padded
    grid on;
    set(gca, 'FontSize', 20);

    % Plot 3: Topography
    nexttile(row * 3 + 3);
    topoplot(mean(rAllElec(:, :, stimidx), 2), eeg.chanlocs, 'electrodes', 'off');
    title([char(stim.names{stimidx}), ' Topography'], 'FontSize', 22);
    colorbar;
    caxis([-0.1, 0.1]);
    set(gca, 'FontSize', 20);

    % Saving Results 
    savepath = fullfile(['C:\Users\holly\OneDrive\Documents\MATLAB\Data analysis\HyperScanning\resultsPilot', '\results_', int2str(stimidx), '.mat']);
    save(savepath, 'rAll', 'modelAll', 'avgModel', 'best_lambda', 'statsAll', 'lambdas', 'featname', 'bestLambda');
end

% Save figure
saveas(gcf, 'C:\Users\holly\OneDrive\Documents\Dissertation\Figs\Evaluation\Pilot6.png');
