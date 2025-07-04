extends Control

@onready var back: Button = $VBoxContainer/Back

func _ready() -> void:
	back.grab_focus()

func _on_back_pressed() -> void:
	SceneSwitcher.return_from_scene()


func _on_main_menu_pressed() -> void:
	SceneSwitcher.go_to_main_menu(true)
