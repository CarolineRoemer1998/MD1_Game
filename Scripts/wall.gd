extends Node2D

@export var buttons: Array[NodePath] = [] # Set this from the editor

@onready var button_refs: Array = []
@onready var collider: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

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
			#_activate_wall()
			return
	
	_deactivate_wall()

func _deactivate_wall():
	if wall_active:
		wall_active = false
		collider.disabled = true
		print("Collider disabled:", collider.disabled)
		sprite.modulate = Color(1, 1, 1, 0.3)
		print("Wall deactivated!")

func _activate_wall():
	if not wall_active:
		wall_active = true
		collider.disabled = false
		print("Collider disabled:", collider.disabled)
		sprite.modulate = Color(1, 1, 1, 1)
		print("Wall activated!")
