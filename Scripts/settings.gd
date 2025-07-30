extends Control

@onready var back: Button = $VBoxContainer/Back
@onready var fullscreen_toggle: CheckButton = $VBoxContainer/FullscreenToggle


var used_controller = false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Player_Down") or Input.is_action_just_pressed("Player_Up") or Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Right") )and not used_controller:
		back.grab_focus()
		used_controller = true
	if OS.has_feature("web"):
		fullscreen_toggle.visible = false
		
func _on_back_pressed() -> void:
	SceneSwitcher.return_from_scene()


func _on_fullsceen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
