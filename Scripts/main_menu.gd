extends Control

var used_controller = false

func _ready() -> void:
	if not AudioManager.is_music_playing:
		#AudioManager.music_player.volume_db = -14
		AudioManager.play_music("res://Sounds/Music/title-track.mp3")

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Player_Down") or Input.is_action_just_pressed("Player_Up") or Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Right") )and not used_controller:
		$VBoxContainer/Start.grab_focus()
		used_controller = true
func _on_start_pressed() -> void:
	SceneSwitcher.go_to_next_level()

func _on_stettings_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/Settings.tscn")

func _on_credits_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/credit_scene.tscn")

func _on_exit_pressed() -> void:
	if OS.has_feature("web"):
		# Optional: Redirect to main menu or show a message
		SceneSwitcher.go_to_main_menu(true)
	else:
		get_tree().quit()

func _on_level_select_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/Level_Select.tscn")
