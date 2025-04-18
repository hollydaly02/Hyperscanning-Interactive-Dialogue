import os
import numpy as np
import librosa
import soundfile as sf
from scipy.signal import butter, filtfilt

# Function to apply a bandpass filter to preserve speech frequencies
def bandpass_filter(audio, lowcut=85.0, highcut=3400.0, fs=16000.0, order=5):
    nyquist = 0.5 * fs
    low = lowcut / nyquist
    high = highcut / nyquist
    b, a = butter(order, [low, high], btype='band')
    y = filtfilt(b, a, audio)
    return y

# Function to reduce general noise (apply bandpass filtering)
def reduce_noise(audio_path, output_path, sr=None):
    # Load the audio file
    audio, sr = librosa.load(audio_path, sr=sr)

    # Step 1: Apply bandpass filter to preserve speech frequencies (85 Hz to 3400 Hz)
    filtered_audio = bandpass_filter(audio, lowcut=85, highcut=3400, fs=sr)

    # Step 2: Save the cleaned audio
    sf.write(output_path, filtered_audio, sr)

# Function to process all audio files in a directory
def process_all_files(input_directory, output_directory):
    # Get list of all audio files in the directory (make sure to use correct file extensions, like .wav)
    audio_files = [f for f in os.listdir(input_directory) if f.endswith('.wav')]
    
    # Process each audio file
    for audio_file in audio_files:
        input_path = os.path.join(input_directory, audio_file)
        output_path = os.path.join(output_directory, f"cleaned_{audio_file}")
        
        # Reduce noise and save the cleaned audio
        reduce_noise(input_path, output_path)
        print(f"Processed {audio_file} and saved to {output_path}")

# Example usage: Process all .wav files in a given directory
input_directory = 'Audio_Pilot1'  # Replace with your folder path
output_directory = 'ReduceNoise'  # Replace with the folder path to save cleaned files

# Ensure the output directory exists
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Process all files in the input directory
process_all_files(input_directory, output_directory)

