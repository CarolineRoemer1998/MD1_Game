extends Control

func _ready() -> void:
	$VBoxContainer/Exit.grab_focus()



func _on_exit_pressed() -> void:
	SceneSwitcher.return_from_scene()
