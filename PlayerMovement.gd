extends CharacterBody2D

class_name Player

const GRID_SIZE := Vector2(64,64)
const MOVE_SPEED := 500.0

var target_position: Vector2
var is_moving := false
var buffered_direction := Vector2.ZERO

var hovering_over : Node = null
var currently_possessed_creature : Creature = null

func _ready():
	target_position = position.snapped(GRID_SIZE/2)
	position = target_position

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var direction: Vector2 = Vector2.ZERO

		match event.keycode:
			KEY_W:
				direction = Vector2.UP
			KEY_S:
				direction = Vector2.DOWN
			KEY_A:
				direction = Vector2.LEFT
			KEY_D:
				direction = Vector2.RIGHT
			
			# check if player possesses creature
			KEY_F:
				if hovering_over != null and hovering_over is Creature and currently_possessed_creature == null:
					currently_possessed_creature = hovering_over
				elif currently_possessed_creature is Creature:
					currently_possessed_creature = null

		if direction != Vector2.ZERO:
			if is_moving:
				buffered_direction = direction
			else:
				try_move(direction)

func _process(delta):
	if is_moving:
		position = position.move_toward(target_position, MOVE_SPEED * delta)
		
		# move creature if possessing
		if currently_possessed_creature != null:
			currently_possessed_creature.position = currently_possessed_creature.position.move_toward(target_position, MOVE_SPEED * delta)
		
		if position == target_position:
			is_moving = false

			if buffered_direction != Vector2.ZERO:
				try_move(buffered_direction)
				buffered_direction = Vector2.ZERO

func try_move(direction: Vector2):
	var new_pos = target_position + direction * GRID_SIZE
	var space_state = get_world_2d().direct_space_state

	var query := PhysicsPointQueryParameters2D.new()
	query.position = new_pos
	query.collision_mask = 1

	var result = space_state.intersect_point(query, 1)
	if result.is_empty():
		# Kein Objekt – normal bewegen
		target_position = new_pos
		is_moving = true
		return

	var obj = result[0].collider
	if not obj.is_in_group("pushable"):
		return

	# Prüfe ob Ziel hinter dem Pushable frei ist
	var push_target = new_pos + direction * GRID_SIZE
	var push_query := PhysicsPointQueryParameters2D.new()
	push_query.position = push_target
	push_query.collision_mask = 1

	var push_result = space_state.intersect_point(push_query, 1)
	if push_result.is_empty():
		if obj.push(direction):
			target_position = new_pos
			is_moving = true
		else:
			buffered_direction = Vector2.ZERO

func _on_creature_detected(creature: Node) -> void:
	if creature is Creature:
		hovering_over = creature


func _on_creature_undetected(creature: Node) -> void:
	if creature is Creature:
		hovering_over = null
