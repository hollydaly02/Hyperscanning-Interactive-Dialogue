import os
import librosa
import numpy as np
import soundfile as sf  # For saving audio files
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# Load the audio file
audio_path = 'Interview.wav'
audio, sr = librosa.load(audio_path, sr=None)

# Parameters
segment_duration = 1  # Duration in seconds
num_samples_per_segment = segment_duration * sr
n_mfcc = 13  # Number of MFCC features to extract

# Calculate MFCCs and segment the audio
mfccs = []
segments = []  # To store audio segments corresponding to each MFCC
for start in range(0, len(audio), num_samples_per_segment):
    end = min(start + num_samples_per_segment, len(audio))
    segment_audio = audio[start:end]
    
    # Calculate MFCCs for the segment
    mfcc = librosa.feature.mfcc(y=segment_audio, sr=sr, n_mfcc=n_mfcc)
    
    # Pad the MFCCs to ensure consistent shape
    if mfcc.shape[1] < 50:  # Example padding length, adjust as needed
        mfcc = np.pad(mfcc, ((0, 0), (0, 50 - mfcc.shape[1])), mode='constant')
    elif mfcc.shape[1] > 50:  # If it's too long, truncate it
        mfcc = mfcc[:, :50]

    mfccs.append(mfcc)
    segments.append(segment_audio)  # Store the original audio segment

# Stack all MFCCs and reshape for clustering
mfccs = np.concatenate(mfccs, axis=1).T  # Transpose for clustering

# Scale the MFCCs
scaler = StandardScaler()
mfccs_scaled = scaler.fit_transform(mfccs)

# Perform KMeans clustering
n_clusters = 2  # Adjust based on the expected number of speakers
kmeans = KMeans(n_clusters=n_clusters, n_init=10)  # Explicitly set n_init to avoid warning
speaker_labels = kmeans.fit_predict(mfccs_scaled)

# Print the number of segments and labels for debugging
print(f"Total segments: {len(segments)}")
print(f"Speaker labels: {speaker_labels}")

# Create output directory for speaker audio files
output_dir = 'diarized_speakers'
os.makedirs(output_dir, exist_ok=True)

# Initialize lists to hold audio for each speaker
speaker_audio_segments = {i: [] for i in range(n_clusters)}  # Create empty lists for each cluster

# Append each segment's audio to the respective speaker list
for i, label in enumerate(speaker_labels):
    if label in speaker_audio_segments:  # Ensure the label is valid
        speaker_audio_segments[label].append(segments[i])

# Save each speaker's audio as separate files
for speaker_index, audio_segments in speaker_audio_segments.items():
    if audio_segments:  # Only process if there are segments for this speaker
        # Concatenate all segments for this speaker
        combined_audio = np.concatenate(audio_segments)
        # Define output file name
        output_file_path = f"{output_dir}/speaker_{speaker_index + 1}.wav"
        # Save the combined audio
        sf.write(output_file_path, combined_audio, sr)
    else:
        print(f"No segments found for Speaker {speaker_index + 1}.")

print(f"Audio files saved to {output_dir}.")
