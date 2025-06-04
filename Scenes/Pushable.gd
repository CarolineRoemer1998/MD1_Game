extends CharacterBody2D

class_name Pushable

const GRID_SIZE := Vector2(64, 64)
const MOVE_SPEED := 500.0

var target_position: Vector2
var is_moving := false

func _ready():
	target_position = position.snapped(GRID_SIZE / 2)
	position = target_position

func push(direction: Vector2) -> bool:
	if is_moving:
		return false

	target_position += direction * GRID_SIZE
	is_moving = true
	return true

func _process(delta):
	if is_moving:
		position = position.move_toward(target_position, MOVE_SPEED * delta)
		if position == target_position:
			is_moving = false
