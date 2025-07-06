extends Node

@onready var sfx_player = $SFXAudioPlayer
@onready var music_player = $MusicAudioPlayer

var is_music_playing = false

func play_sfx(path: String):
	sfx_player.stream = load(path)
	sfx_player.play()

func play_music(path: String):
	music_player.stream = load(path)
	is_music_playing = true
	music_player.play()
	print ("music Playing")

func stop_music():
	music_player.stop()
	is_music_playing = false
