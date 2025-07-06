extends Control

@onready var back: Button = $VBoxContainer/Back

var cooldown_timer: float = 0.2

func _ready() -> void:
	back.grab_focus()
	
func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		return
	if Input.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _on_back_pressed() -> void:
	SceneSwitcher.return_from_scene()


func _on_main_menu_pressed() -> void:
	SceneSwitcher.go_to_main_menu(true)
