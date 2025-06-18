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
	get_tree().quit()
