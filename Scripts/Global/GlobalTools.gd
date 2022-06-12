extends Node

# load audio file
func loadAudio(path) -> AudioStreamSample:
	var audio_loader = AudioLoader.new()
	return audio_loader.loadfile(path)

#load text/raw file
func loadText(path) -> String:
	var f = File.new()
	var fileInText = ""
	
	f.open(path, File.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		fileInText += line + "\n"
	f.close()
	return fileInText

func fwdToBackSlash(text) -> String:
	var a = text.replace("\\", "/")
	return a
