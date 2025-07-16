extends Control

@onready var back: Button = $VBoxContainer/Back

var cooldown_timer: float = 0.2

var used_controller = false

func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		return
	if (Input.is_action_just_pressed("Player_Down") or Input.is_action_just_pressed("Player_Up") or Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Right") )and not used_controller:
		back.grab_focus()
		used_controller = true
	if Input.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _on_back_pressed() -> void:
	SceneSwitcher.return_from_scene()


func _on_main_menu_pressed() -> void:
	SceneSwitcher.go_to_main_menu(true)
