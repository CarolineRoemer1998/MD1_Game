extends Node2D

signal activated
signal deactivated

enum BUTTON_TYPE {TOGGLE, STICKY, PRESSURE, COMBINATION}

@export var type : BUTTON_TYPE = BUTTON_TYPE.STICKY

var active: bool = false

@onready var button_green: Sprite2D = $Button_GREEN
@onready var button_red: Sprite2D = $Button_RED
@onready var area: Area2D = $Area2D
@onready var audio_push_button: AudioStreamPlayer2D = $AudioPushButton
@onready var audio_leave: AudioStreamPlayer2D = $AudioLeave

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_update_button_color()

func _on_body_entered(body: Node) -> void:
	if not active:
		set_active(true)
		emit_signal("activated")
		audio_push_button.play()

func _on_body_exited(body: Node) -> void:
	# Optional: only deactivate if no bodies are left
	await get_tree().process_frame # small delay to update collision state
	if area.get_overlapping_bodies().is_empty():
		set_active(false)
		emit_signal("deactivated")
		audio_leave.play()

func _update_button_color() -> void:
	button_green.visible = active
	button_red.visible = not active

func is_pressed() -> bool:
	return active

func set_active(value : bool):
	active = value
	_update_button_color()
