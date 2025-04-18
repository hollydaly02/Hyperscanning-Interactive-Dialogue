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

%% Loop over all stimulus indices (1 = Env, 2 = Env', 3 = Env+Env')
for stimidx = 1:3
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
        [maxR, bestLambda] = max(squeeze(mean(mean(stats.r, 1), 3))); % Get the best lambda
        disp(['Best Lambda: ', num2str(lambdas(bestLambda)), ' with r = ', num2str(maxR)]);

        rAll(sub) = maxR;
        statsAll(sub) = stats;
        best_lambda(sub) = lambdas(bestLambda);
        rAllElec(:, sub) = squeeze(mean(stats.r(:, bestLambda, :), 1));

        % Train TRF model
        disp('Running mTRFtrain...');
        model = mTRFtrain(stimFeature.data, eeg.data, eeg.fs, dirTRF, tmin, tmax, lambdas(bestLambda), 'verbose', 0);
        modelAll(sub) = model;
    end

    % Compute averaged TRF model after all subjects are processed
    normFlag = 0;
    avgModel = mTRFmodelAvg(modelAll, normFlag);

    %% Plot TRF and GFP for each stimulus index
    figure;

    % Plot Envelope TRF 
    subplot(2, 2, 1);
    hold on;
    for sub = 1:nSubs
        plot(t, squeeze(modelAll(sub).w(1, :, :)), 'LineWidth', 1);
    end
    title(['Envelope TRF - ', featname]);
    xlabel('Time-latency (ms)'); ylabel('Magnitude (a.u.)');
    xlim([tmin, tmax]);  
    grid on;

    % Plot GFP for Envelope
    subplot(2, 2, 2);
    area(t, std(squeeze(modelAll(1).w(1, :, :)), 0, 2), 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'none');
    title(['GFP - Envelope - ', featname]);
    xlabel('Time-latency (ms)'); ylabel('Magnitude (a.u.)');
    xlim([tmin, tmax]);  
    grid on;

    % **Check if second feature (Env') exists before plotting**
    if size(modelAll(1).w, 1) > 1
        % Plot Envelope Derivative TRF
        subplot(2, 2, 3);
        hold on;
        for sub = 1:nSubs
            plot(t, squeeze(modelAll(sub).w(2, :, :)), 'LineWidth', 1);
        end
        title(['Envelope Derivative TRF - ', featname]);
        xlabel('Time-latency (ms)'); ylabel('Magnitude (a.u.)');
        xlim([tmin, tmax]);  
        grid on;

        % Plot GFP for Envelope Derivative
        subplot(2, 2, 4);
        area(t, std(squeeze(modelAll(1).w(2, :, :)), 0, 2), 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'none');
        title(['GFP - Envelope Derivative - ', featname]);
        xlabel('Time-latency (ms)'); ylabel('Magnitude (a.u.)');
        xlim([tmin, tmax]);  
        grid on;
    else
        disp(['Skipping Envelope Derivative TRF for ', featname, ' (Only one feature available)']);
    end

    %% Save the results for each stimidx separately
    savepath = fullfile(['C:\Users\holly\OneDrive\Documents\MATLAB\Data analysis\HyperScanning\resultsPilot', '\results_', int2str(stimidx), '.mat']);
    save(savepath, 'rAll', 'modelAll', 'avgModel', 'best_lambda', 'statsAll', 'lambdas', 'featname', 'bestLambda');
end
