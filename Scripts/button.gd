extends Node2D

signal activated
signal deactivated

var active: bool = false

@onready var button_green: Sprite2D = $Button_GREEN
@onready var button_red: Sprite2D = $Button_RED
@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_update_button_color()

func _on_body_entered(body: Node) -> void:
	if not active:
		active = true
		_update_button_color()
		print(active)
		emit_signal("activated")

func _on_body_exited(body: Node) -> void:
	# Optional: only deactivate if no bodies are left
	await get_tree().process_frame # small delay to update collision state
	if area.get_overlapping_bodies().is_empty():
		active = false
		_update_button_color()
		print(active)
		emit_signal("deactivated")

func _update_button_color() -> void:
	button_green.visible = active
	button_red.visible = not active

func is_pressed() -> bool:
	return active
