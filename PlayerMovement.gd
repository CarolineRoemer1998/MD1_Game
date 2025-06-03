extends CharacterBody2D
class_name Player

const GRID_SIZE := Vector2(64, 64)
const MOVE_SPEED := 500.0

var target_position: Vector2
var is_moving := false
var buffered_direction: Vector2 = Vector2.ZERO

var hovering_over: Creature = null
var currently_possessed_creature: Creature = null
var possessed_creature_until_next_tile: Creature = null


@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready():
	# Spieler korrekt auf Grid ausrichten
	target_position = position.snapped(GRID_SIZE / 2)
	position = target_position


func _process(delta):
	move(delta)


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var direction := Vector2.ZERO

		# Bewegungsrichtungen abfragen
		match event.keycode:
			KEY_W: 
				direction = Vector2.UP
			KEY_S: 
				direction = Vector2.DOWN
			KEY_A: 
				direction = Vector2.LEFT
			KEY_D: 
				direction = Vector2.RIGHT
				
			KEY_F: 
				possess_or_unpossess_creature()

		# Bewegungsversuch oder Puffern bei laufender Bewegung
		if direction != Vector2.ZERO:
			if is_moving:
				buffered_direction = direction
			else:
				try_move(direction)


func move(delta):
	if is_moving:
		position = position.move_toward(target_position, MOVE_SPEED * delta)

		if possessed_creature_until_next_tile:
			# Besessene Kreatur mitziehen
			possessed_creature_until_next_tile.position = possessed_creature_until_next_tile.position.move_toward(
				target_position, MOVE_SPEED * delta
			)

			# Bewegung abgeschlossen → Entkoppeln
			if possessed_creature_until_next_tile.position == target_position:
				possessed_creature_until_next_tile = null

		if position == target_position:
			set_is_moving(false)

			# Pufferbewegung ausführen
			if buffered_direction != Vector2.ZERO:
				try_move(buffered_direction)
				buffered_direction = Vector2.ZERO


func try_move(direction: Vector2):
	var new_pos = target_position + direction * GRID_SIZE
	var space_state = get_world_2d().direct_space_state
	merge_if_possible(direction)
	# Prüfen ob ein Objekt am Zielort ist
	var query := PhysicsPointQueryParameters2D.new()
	query.position = new_pos
	query.collision_mask = 1
	var result = space_state.intersect_point(query, 1)

	# Kein Objekt: Bewegung frei
	if result.is_empty():
		target_position = new_pos
		set_is_moving(true)
		return
		
	# Objekt vorhanden, prüfen ob pushable
	try_push_and_move(result, new_pos, direction, space_state)


func merge_if_possible(direction : Vector2) -> bool:
	if currently_possessed_creature != null:
		match direction:
			Vector2(1.0, 0.0): # right
				if currently_possessed_creature.neighbor_right != null:
					if currently_possessed_creature.can_merge_with(currently_possessed_creature.neighbor_right):
						print("MERGE WITH RIGHT")
						return true
			Vector2(0.0, 1.0): # bottom
				if currently_possessed_creature.neighbor_bottom != null:
					if currently_possessed_creature.can_merge_with(currently_possessed_creature.neighbor_bottom):
						print("MERGE WITH BOTTOM")
						return true
			Vector2(-1.0, 0.0): # left
				if currently_possessed_creature.neighbor_left != null:
					if currently_possessed_creature.can_merge_with(currently_possessed_creature.neighbor_left):
						print("MERGE WITH LEFT")
						return true
			Vector2(0.0, -1.0): # top
				if currently_possessed_creature.neighbor_top != null:
					if currently_possessed_creature.can_merge_with(currently_possessed_creature.neighbor_top):
						print("MERGE WITH TOP")
						return true
	return false

func try_push_and_move(object_to_push, new_pos, direction, space_state):
	# Objekt vorhanden, prüfen ob pushable
	var obj = object_to_push[0].collider
	if not obj.is_in_group("pushable"):
		return

	# Ziel hinter dem pushable prüfen
	var push_target = new_pos + direction * GRID_SIZE
	var push_query := PhysicsPointQueryParameters2D.new()
	push_query.position = push_target
	push_query.collision_mask = 1
	var push_result = space_state.intersect_point(push_query, 1)

	# Falls frei, push ausführen
	if push_result.is_empty() and obj.push(direction):
		target_position = new_pos
		set_is_moving(true)
	else:
		buffered_direction = Vector2.ZERO


func set_is_moving(value: bool):
	is_moving = value

	# Falls Spieler etwas besitzt und Bewegung beginnt, merken
	if value and currently_possessed_creature:
		possessed_creature_until_next_tile = currently_possessed_creature


func possess_or_unpossess_creature():
	if currently_possessed_creature:
		# Unpossess: Sichtbarkeit zurücksetzen
		if is_instance_valid(currently_possessed_creature):
			currently_possessed_creature.border.visible = false

		currently_possessed_creature = null
		sprite_2d.modulate = Color(1, 1, 1, 0.6)

	else:
		# Possess: Übernehmen und sofort synchronisieren
		if hovering_over and hovering_over is Creature:
			currently_possessed_creature = hovering_over
			currently_possessed_creature.border.visible = true
			sprite_2d.modulate = Color(1, 1, 1, 0.1)

			# Position sofort synchronisieren
			currently_possessed_creature.position = target_position
			currently_possessed_creature.target_position = target_position

			possessed_creature_until_next_tile = currently_possessed_creature


func _on_creature_detected(creature: Node) -> void:
	if creature is Creature:
		if currently_possessed_creature == null:
			hovering_over = creature
		else:
			# Merge Möglichkeit eröffnen
			pass
			


func _on_creature_undetected(creature: Node) -> void:
	if creature is Creature and hovering_over == creature:
		hovering_over = null
