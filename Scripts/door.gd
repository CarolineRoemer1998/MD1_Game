extends Node2D

class_name Door

@export var buttons: Array[NodePath] = [] # Set this from the editor
@export var door_can_close: bool = false

@onready var button_refs: Array = []
@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var opened_door_sprite := preload("res://Sprites/fence-gate-open.png")
var closed_door_sprite := preload("res://Sprites/fence-gate-closed.png")

var wall_active := true

func _ready():
	# Resolve NodePaths to actual button nodes
	for path in buttons:
		var button = get_node(path)
		if button:
			button_refs.append(button)
			button.activated.connect(_on_button_state_changed)
			button.deactivated.connect(_on_button_state_changed)
	
	_check_buttons()

func _on_button_state_changed():
	_check_buttons()

func _check_buttons():
	for button in button_refs:
		if not button.is_pressed():
			if door_can_close:
				_close_door()
			return
	_open_door()

func _open_door():
	if wall_active:
		wall_active = false
		collider.disabled = true
		print("Collider disabled:", collider.disabled)
		sprite.texture = opened_door_sprite
		print("Wall deactivated!")

func _close_door():
	if not wall_active:
		wall_active = true
		collider.disabled = false
		print("Collider disabled:", collider.disabled)
		sprite.texture = closed_door_sprite
		print("Wall activated!")
