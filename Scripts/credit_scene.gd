extends Control

@onready var back: Button = $VBoxContainer2/Back

func _ready() -> void:
	back.grab_focus()



func _on_exit_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/MainMenu.tscn")
