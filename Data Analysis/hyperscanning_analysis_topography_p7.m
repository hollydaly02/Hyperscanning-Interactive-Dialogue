%% Running TRF Analysis
clear
dataMainFolder = 'C:\Users\holly\OneDrive\Documents\MATLAB\Data analysis\HyperScanning\pilots';
dataCNDSubfolder = '\Pilot7\dataCND\';

tmin = -200;
tmax = 1000;
lambdas = [1e-8, 1e-6, 1e-4, 1e-2, 1e0, 1e2, 1e4, 1e6, 1e8];
dirTRF = 1;  % Forward TRF model
stimidx = 3;  % Refer to preprocessing for correct index

%eegFilenames = dir([dataMainFolder,dataCNDSubfolder,'pre1_SepdataSub*.mat']);
eegFilenames = dir(fullfile(dataMainFolder, dataCNDSubfolder, 'prebroadband100sr_pre_dataSub*.mat'));
nSubs = length(eegFilenames);

%%
for sub = 1:nSubs
    % Loading preprocessed EEG
    %eegPreFilename = [eegFilenames(sub).folder,'\prebroadband100sr_',eegFilenames(sub).name]
    eegPreFilename = fullfile(eegFilenames(sub).folder, eegFilenames(sub).name);
    stimFilename = [eegFilenames(sub).folder,'\LallNorm_datastim2Sub',int2str(sub),'.mat'] % be carful
    disp(['Loading preprocessed EEG data: prebroadband_', eegFilenames(sub).name])
    load(eegPreFilename, 'eeg')
    eeg.fs = double(eeg.fs);
    disp(['Loading stimulus data: ', 'dataStim.mat'])
    load(stimFilename)

    stimFeature = stim;
    stimFeature.data = stimFeature.data(stimidx, :);

    % Ensuring matching length between stimulus and EEG data
    if eeg.fs ~= stimFeature.fs
        disp('Error: EEG and STIM have different sampling frequency')
        return
    end
    if length(eeg.data) ~= length(stimFeature.data)
        disp('Error: EEG.data and STIM.data have different number of trials')
        return
    end
    for tr = 1:length(stimFeature.data)
        envLen = size(stimFeature.data{tr}, 1);
        eegLen = size(eeg.data{tr}, 1);
        minLen = min(envLen, eegLen);
        stimFeature.data{tr} = double(stimFeature.data{tr}(1:minLen, :));
        eeg.data{tr} = double(eeg.data{tr}(1:minLen, :));
    end

    % Normalizing EEG data
    clear tmpEnv tmpEeg
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

    % Running mTRF cross-validation
    [stats, t] = mTRFcrossval(stimFeature.data, eeg.data, eeg.fs, dirTRF, tmin, tmax, lambdas, 'verbose', 0);
    [maxR, bestLambda] = max(squeeze(mean(mean(stats.r, 1), 3))); % Get the best lambda
    disp(['r = ', num2str(maxR)])
    rAll(sub) = maxR;
    statsAll(sub) = stats;
    best_lambda(sub) = lambdas(bestLambda);
    rAllElec(:,sub) = squeeze(mean(stats.r(:,bestLambda,:),1));
    disp('Running mTRFtrain')

    % Training the TRF model with the best lambda
    model = mTRFtrain(stimFeature.data, eeg.data, eeg.fs, dirTRF, tmin, tmax, lambdas(bestLambda), 'verbose', 0);
    modelAll(sub) = model;
    normFlag = 0;
    avgModel = mTRFmodelAvg(modelAll, normFlag);
end

%% Plot TRF and GFP
figure;
set(gcf, 'Color', 'w');
tiledlayout(2,3, 'Padding', 'compact', 'TileSpacing', 'compact');

% Plot 1: Envelope TRF
nexttile;
hold on;
for sub = 1:nSubs
    plot(t, squeeze(modelAll(sub).w(1, :, :)), 'LineWidth', 1);
end
title('Envelope TRF', 'FontSize', 22);
xlabel('Time-latency (ms)', 'FontSize', 20);
ylabel('Magnitude (a.u.)', 'FontSize', 20);
xlim([tmin, tmax]);
xticks(tmin:200:tmax);
grid on;
set(gca, 'FontSize', 20);

% Plot 2: GFP - Envelope
nexttile;
area(t, std(squeeze(modelAll(1).w(1, :, :)), 0, 2), ...
    'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'none');
title('Envelope GFP', 'FontSize', 22);
xlabel('Time-latency (ms)', 'FontSize', 20);
ylabel('Magnitude (a.u.)', 'FontSize', 20);
xlim([tmin, tmax]);
xticks(tmin:200:tmax);
grid on;
set(gca, 'FontSize', 20);

% Plot 3: Topography
for ch = 1:length(eeg.chanlocs)
    % Flatten any nested cell/array to scalar
    eeg.chanlocs(ch).theta = double(eeg.chanlocs(ch).theta(:));
    eeg.chanlocs(ch).radius = double(eeg.chanlocs(ch).radius(:));
    if numel(eeg.chanlocs(ch).theta) > 1
        eeg.chanlocs(ch).theta = eeg.chanlocs(ch).theta(1);
    end
    if numel(eeg.chanlocs(ch).radius) > 1
        eeg.chanlocs(ch).radius = eeg.chanlocs(ch).radius(1);
    end
end

nexttile;
topoplot(mean(rAllElec, 2), eeg.chanlocs, 'electrodes', 'off');
title('Prediction Correlation (Topography)', 'FontSize', 22);
colorbar;
caxis([-0.1, 0.1]);
set(gca, 'FontSize', 20);

% Plot 4: Envelope Derivative TRF
nexttile;
hold on;
for sub = 1:nSubs
    plot(t, squeeze(modelAll(sub).w(2, :, :)), 'LineWidth', 1);
end
title('Envelope Derivative TRF', 'FontSize', 22);
xlabel('Time-latency (ms)', 'FontSize', 20);
ylabel('Magnitude (a.u.)', 'FontSize', 20);
xlim([tmin, tmax]);
xticks(tmin:200:tmax);
grid on;
set(gca, 'FontSize', 20);

% Plot 5: GFP - Envelope Derivative
nexttile;
area(t, std(squeeze(modelAll(1).w(2, :, :)), 0, 2), ...
    'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'none');
title('Envelope Derivative GFP', 'FontSize', 22);
xlabel('Time-latency (ms)', 'FontSize', 20);
ylabel('Magnitude (a.u.)', 'FontSize', 20);
xlim([tmin, tmax]);
xticks(tmin:200:tmax);
grid on;
set(gca, 'FontSize', 20);


%% Save the results
savepath = fullfile(['C:\Users\holly\OneDrive\Documents\MATLAB\Data analysis\HyperScanning\resultsPilot', '\results', int2str(stimidx), '.mat']);
save(savepath, 'rAll', 'modelAll', 'avgModel', 'best_lambda', 'statsAll', 'lambdas', 'featname', 'bestLambda');
