from pydub import AudioSegment
import speech_recognition as sr
import io

# Load the audio file
sound = AudioSegment.from_wav("Interview.wav")

# Define the length of each segment (in milliseconds)
segment_length = 60 * 1000  # 1 minute
total_length = len(sound)  # Total length of the audio in milliseconds
transcription_results = []

# Initialize the recognizer
r = sr.Recognizer()

# Loop through the audio in segments
for start_time in range(0, total_length, segment_length):
    end_time = start_time + segment_length
    # Ensure the end time does not exceed the total length
    if end_time > total_length:
        end_time = total_length
    
    # Get the segment
    segment = sound[start_time:end_time]

    # Create an in-memory buffer for the audio segment
    audio_buffer = io.BytesIO()
    segment.export(audio_buffer, format="wav")
    audio_buffer.seek(0)  # Go to the start of the BytesIO buffer

    # Use the AudioFile with the in-memory buffer
    with sr.AudioFile(audio_buffer) as source:
        audio_text = r.record(source)  # Read the audio segment

    # Transcribe the audio
    try:
        transcription = r.recognize_google(audio_text)
        transcription_results.append(f"Transcription of segment {start_time//1000}-{end_time//1000} seconds:\n{transcription}\n")
    except sr.UnknownValueError:
        transcription_results.append(f"Segment {start_time//1000}-{end_time//1000} seconds: Google Speech Recognition could not understand the audio.\n")
    except sr.RequestError as e:
        transcription_results.append(f"Segment {start_time//1000}-{end_time//1000} seconds: Could not request results from Google Speech Recognition service; {e}\n")

# Write the results to a text file
with open("transcriptions.txt", "w") as f:
    f.writelines(transcription_results)

print("Transcription completed. Results saved to 'transcriptions.txt'.")
