clc; clear; close all;

% Create figure
figure;
hold on;
axis off;
title('EEG Experiment Schematic', 'FontSize', 14, 'FontWeight', 'bold');

% Define positions for elements
subject1_pos = [0.1, 0.7, 0.2, 0.2]; % [x, y, width, height]
subject2_pos = [0.7, 0.7, 0.2, 0.2];
monitor_pos = [0.1, 0.9, 0.2, 0.1];
microphone_pos = [0.1, 0.5, 0.15, 0.1];
speaker_pos = [0.7, 0.5, 0.15, 0.1];
eeg1_pos = [0.1, 0.3, 0.2, 0.1];
eeg2_pos = [0.7, 0.3, 0.2, 0.1];
lsl_pos = [0.4, 0.2, 0.2, 0.1];
analysis_pos = [0.4, 0.05, 0.2, 0.1];

% Add text labels
text(0.2, 0.95, 'Monitor (Question Display)', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.2, 0.75, 'Subject 1 (EEG + Speaking)', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.8, 0.75, 'Subject 2 (EEG + Listening)', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.2, 0.55, 'Microphone (Audio Capture)', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.8, 0.55, 'Speaker (Passive Listening)', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.2, 0.35, 'mBrainTrain EEG Device 1', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.8, 0.35, 'mBrainTrain EEG Device 2', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.5, 0.25, 'LSL Sync (LAN Connection)', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(0.5, 0.1, 'TRF Analysis', 'FontSize', 10, 'HorizontalAlignment', 'center');

% Draw rectangles to represent elements
rectangle('Position', subject1_pos, 'FaceColor', [0.7 0.9 1], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', subject2_pos, 'FaceColor', [0.7 0.9 1], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', monitor_pos, 'FaceColor', [1 0.9 0.6], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', microphone_pos, 'FaceColor', [0.6 1 0.6], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', speaker_pos, 'FaceColor', [0.6 1 0.6], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', eeg1_pos, 'FaceColor', [0.8 0.7 1], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', eeg2_pos, 'FaceColor', [0.8 0.7 1], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', lsl_pos, 'FaceColor', [1 0.6 0.6], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', analysis_pos, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 2);

% Draw arrows
annotation('arrow', [0.2 0.2], [0.9 0.8]); % Monitor -> Subject 1
annotation('arrow', [0.8 0.8], [0.9 0.8]); % Monitor -> Subject 2
annotation('arrow', [0.2 0.2], [0.7 0.6]); % Subject 1 -> Microphone
annotation('arrow', [0.8 0.8], [0.7 0.6]); % Subject 2 -> Speaker
annotation('arrow', [0.2 0.2], [0.5 0.4]); % Microphone -> EEG 1
annotation('arrow', [0.8 0.8], [0.5 0.4]); % Speaker -> EEG 2
annotation('arrow', [0.2 0.4], [0.35 0.25]); % EEG 1 -> LSL Sync
annotation('arrow', [0.8 0.6], [0.35 0.25]); % EEG 2 -> LSL Sync
annotation('arrow', [0.5 0.5], [0.2 0.1]); % LSL Sync -> TRF Analysis

% Add EEG and stimulus figures (update paths with actual figure files)
eeg_img = imread('robot.jpg'); % Provide EEG waveform image
stim_img = imread('sim.png'); % Provide spectrogram image
trf_img = imread('sim.png'); % Provide TRF heatmap image

% Display images in relevant locations
axes('Position', [0.4, 0.6, 0.2, 0.15]); imshow(eeg_img);
axes('Position', [0.1, 0.6, 0.2, 0.15]); imshow(stim_img);
axes('Position', [0.5, 0.02, 0.2, 0.1]); imshow(trf_img);

hold off;
