extends Control

@onready var back: Button = $VBoxContainer/Back


func _ready():
	back.grab_focus()

func _on_back_pressed() -> void:
	SceneSwitcher.return_from_scene()
