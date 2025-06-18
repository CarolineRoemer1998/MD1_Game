extends Control

func _ready() -> void:
	$VBoxContainer/Exit.grab_focus()



func _on_exit_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/MainMenu.tscn")
