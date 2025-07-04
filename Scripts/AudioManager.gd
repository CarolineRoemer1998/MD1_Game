extends Node

@onready var sfx_player = $SFXAudioPlayer
@onready var music_player = $MusicAudioPlayer

func play_sfx(path: String):
	sfx_player.stream = load(path)
	sfx_player.play()

func play_music(path: String, loop := true):
	music_player.stream = load(path)
	music_player.loop = loop
	music_player.play()

func stop_music():
	music_player.stop()
