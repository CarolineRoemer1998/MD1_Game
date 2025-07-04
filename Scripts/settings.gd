extends Control



func _ready():
	$VBoxContainer/Back.grab_focus()

func _on_back_pressed() -> void:
	SceneSwitcher.return_from_scene()
