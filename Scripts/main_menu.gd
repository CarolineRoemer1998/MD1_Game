extends Control


func _ready() -> void:
	$VBoxContainer/Start.grab_focus()

func _on_start_pressed() -> void:
	SceneSwitcher.go_to_next_level()


func _on_stettings_pressed() -> void:
	SceneSwitcher.go_to_settings()


func _on_exit_pressed() -> void:
	get_tree().quit()
