from pydub import AudioSegment

# Load the stereo audio file
input_file = "Audio_Pilot1/Sub1_2-002-20241128162710.wav"
audio = AudioSegment.from_file(input_file)

# Check if the audio file is stereo (has two channels)
if audio.channels == 2:
    # Split the stereo audio into two mono tracks
    left_channel = audio.split_to_mono()[0]  # Left channel
    right_channel = audio.split_to_mono()[1]  # Right channel

    # Export each channel as a separate file
    left_channel.export("speaker_left.wav", format="wav")
    right_channel.export("speaker_right.wav", format="wav")
    print("Exported left and right channels as separate mono audio files.")
else:
    print("The audio file is not stereo, so it cannot be split into two channels.")
