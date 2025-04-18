# Import the required module for text to speech conversion
from gtts import gTTS

# The text that you want to convert to audio
mytext = 'The question of whether the minimum age to vote should be lowered to 16 has sparked significant debate. Some argue that 16 year olds are mature enough to make informed decisions, as they are directly affected by political issues like education and employment. Lowering the voting age could also increase political engagement among young people. However, others believe 16 year olds lack the life experience necessary to vote responsibly. So, should the voting age be lowered to 16, or remain at 18 to ensure voters are fully prepared?'

# Language in which you want to convert
language = 'en'

# Passing the text and language to the engine, with slow =False, so the speed is high
myobj = gTTS(text=mytext, lang=language, slow=False)

# Saving the converted audio in a wav file 
myobj.save("test22.mp3")

print('mp3 saved')