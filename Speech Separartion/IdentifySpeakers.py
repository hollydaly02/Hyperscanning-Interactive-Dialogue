import librosa
import numpy as np
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# Load the audio file
audio_path = 'Audio_Pilot1/Sub1_2-002-20241128162710.wav'
audio, sr = librosa.load(audio_path, sr=None)

# Parameters
segment_duration = 1  # Duration in seconds
num_samples_per_segment = segment_duration * sr
n_mfcc = 13  # Number of MFCC features to extract

# Calculate MFCCs and segment the audio
mfccs = []
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

# Stack all MFCCs and reshape for clustering
mfccs = np.concatenate(mfccs, axis=1).T  # Transpose for clustering

# Scale the MFCCs
scaler = StandardScaler()
mfccs_scaled = scaler.fit_transform(mfccs)

# Perform KMeans clustering
n_clusters = 2  # Adjust based on the expected number of speakers
kmeans = KMeans(n_clusters=n_clusters)
speaker_labels = kmeans.fit_predict(mfccs_scaled)

# Print the results
for i, label in enumerate(speaker_labels):
    print(f"Segment {i}: Speaker {label}")
