extends Control


func _ready() -> void:
	$VBoxContainer/Start.grab_focus()

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
