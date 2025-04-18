import os
from pydub import AudioSegment

# Create the 'wav' folder if it doesn't exist
if not os.path.exists("wav"):
    os.makedirs("wav")

# Loop over the files in the 'mp3' folder
for i in range(1, 23):  # Process Audio1.mp3 to Audio23.mp3
    mp3_filename = f"mp3/Audio{i}.mp3"  # Input file from mp3 folder
    wav_filename = f"wav/Audio{i}.wav"  # Output file to wav folder
    
    # Load the MP3 file
    sound = AudioSegment.from_mp3(mp3_filename)
    
    # Export as WAV to the 'wav' folder
    sound.export(wav_filename, format="wav")
    print(f"Converted {mp3_filename} to {wav_filename}")
