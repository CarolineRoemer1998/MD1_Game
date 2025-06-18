extends Node2D

signal activated
signal deactivated

enum BUTTON_TYPE {TOGGLE, STICKY, PRESSURE}

@export var type : BUTTON_TYPE = BUTTON_TYPE.STICKY

var active: bool = false
var sticky_audio_played = false

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
	match type:
		BUTTON_TYPE.TOGGLE: 
			toggle_button()
		BUTTON_TYPE.STICKY: 
			sticky_button()
		BUTTON_TYPE.PRESSURE: 
			pressure_button()
	
func _on_body_exited(body: Node) -> void:
	# Optional: only deactivate if no bodies are left
	if type == BUTTON_TYPE.TOGGLE or type == BUTTON_TYPE.STICKY:
		return
		
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

func toggle_button():
	set_active(!active)
	if active:
		emit_signal("activated")
		audio_push_button.play()
	else:
		emit_signal("deactivated")
		audio_leave.play()
	
func sticky_button():
	set_active(true)
	emit_signal("activated")
	if not sticky_audio_played:
		audio_push_button.play()
		sticky_audio_played = true
	
func pressure_button():
	if not active:
		set_active(true)
		emit_signal("activated")
		audio_push_button.play()
