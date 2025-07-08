extends Control

@onready var back: Button = $VBoxContainer/Back

func _ready() -> void:
	back.grab_focus()



func _on_exit_pressed() -> void:
	SceneSwitcher.switch_scene("res://Scenes/Menu/MainMenu.tscn")


func _on_level_1_pressed() -> void:
	SceneSwitcher.switch_to_level(1)


func _on_level_2_pressed() -> void:
	SceneSwitcher.switch_to_level(2)


func _on_level_3_pressed() -> void:
	SceneSwitcher.switch_to_level(3)


func _on_level_4_pressed() -> void:
	SceneSwitcher.switch_to_level(4)


func _on_level_5_pressed() -> void:
	SceneSwitcher.switch_to_level(5)


func _on_level_6_pressed() -> void:
	SceneSwitcher.switch_to_level(6)


func _on_level_7_pressed() -> void:
	SceneSwitcher.switch_to_level(7)


func _on_level_8_pressed() -> void:
	SceneSwitcher.switch_to_level(8)


func _on_level_9_pressed() -> void:
	SceneSwitcher.switch_to_level(9)


func _on_level_10_pressed() -> void:
	SceneSwitcher.switch_to_level(10)
