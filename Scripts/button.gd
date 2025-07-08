extends Node2D

signal activated
signal deactivated

enum BUTTON_TYPE {TOGGLE, STICKY, PRESSURE}

var sprite_sticky_off := preload("res://Sprites/button_unpressed.png")
var sprite_sticky_on := preload("res://Sprites/button_pressed.png")
var sprite_pressure_off := preload("res://Sprites/pressure_plate_off.png")
var sprite_pressure_on := preload("res://Sprites/pressure_plate_on.png")
var sprite_toggle_orange := preload("res://Sprites/toggle-button-orange.png")
var sprite_toggle_purple := preload("res://Sprites/toggle-button-purple.png")

@export var type : BUTTON_TYPE = BUTTON_TYPE.STICKY
@export var start_active: bool = false
var active: bool = false
var sticky_audio_played : bool = false
var door_is_permanently_opened : bool = false


@onready var button_green: Sprite2D = $Button_GREEN
@onready var button_red: Sprite2D = $Button_RED
@onready var area: Area2D = $Area2D
@onready var audio_push_button: AudioStreamPlayer2D = $AudioPushButton
@onready var audio_leave: AudioStreamPlayer2D = $AudioLeave

func _ready() -> void:
	_set_button_sprites()
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	set_active(start_active)
	
	
func _on_body_entered(body: Node) -> void:
	if door_is_permanently_opened:
		return
	
	match type:
		BUTTON_TYPE.TOGGLE: 
			toggle_button()
		BUTTON_TYPE.STICKY: 
			sticky_button()
		BUTTON_TYPE.PRESSURE: 
			pressure_button()
	
func _on_body_exited(body: Node) -> void:
	if door_is_permanently_opened:
		return
	
	# Optional: only deactivate if no bodies are left
	if type == BUTTON_TYPE.TOGGLE or type == BUTTON_TYPE.STICKY:
		return
		
	await get_tree().process_frame # small delay to update collision state
	if area.get_overlapping_bodies().is_empty():
		set_active(false)
		#audio_leave.play()
		AudioManager.play_sfx("res://Sounds/Leave Button 3.mp3")
		
func _update_button_color() -> void:
	button_green.visible = active
	button_red.visible = not active

func is_pressed() -> bool:
	return active

func set_active(value : bool):
	active = value
	if active:
		emit_signal("activated")
	else: 
		emit_signal("deactivated")
	_update_button_color()

func toggle_button():
	set_active(!active)
	if active:
		#audio_push_button.play()
		AudioManager.play_sfx("res://Sounds/Push Button 5.mp3")
	else:
		#audio_leave.play()
		AudioManager.play_sfx("res://Sounds/Leave Button 3.mp3")
	
func sticky_button():
	set_active(true)
	if not sticky_audio_played:
		#audio_push_button.play()
		AudioManager.play_sfx("res://Sounds/Push Button 5.mp3")
		sticky_audio_played = true
	
func pressure_button():
	if not active:
		set_active(true)
		#audio_push_button.play()
		AudioManager.play_sfx("res://Sounds/Push Button 5.mp3")

func _set_button_sprites():
	match type:
		BUTTON_TYPE.TOGGLE:
			button_green.texture = sprite_toggle_orange
			button_red.texture = sprite_toggle_purple
		BUTTON_TYPE.STICKY:
			button_green.texture = sprite_sticky_on
			button_red.texture = sprite_sticky_off
		BUTTON_TYPE.PRESSURE:
			button_green.texture = sprite_pressure_on
			button_red.texture = sprite_pressure_off
			
func set_door_is_permanently_opened():
	door_is_permanently_opened = true
