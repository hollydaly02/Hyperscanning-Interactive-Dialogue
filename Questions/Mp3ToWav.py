from pydub import AudioSegment

# Convert mp3 file to wav and set the correct parameters
src = "test1.mp3"
sound = AudioSegment.from_mp3(src)
sound.export("Audio1.wav", format="wav")
print('wav downloaded')
