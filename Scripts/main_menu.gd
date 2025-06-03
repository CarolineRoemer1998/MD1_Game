extends Control


func _on_start_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Level1.tscn")


func _on_stettings_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/Settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
