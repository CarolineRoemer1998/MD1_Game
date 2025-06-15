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
@export var trail_scene: PackedScene 

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var heart: Sprite2D = $Heart
@onready var label_press_f_to_control: Label = $LabelPressFToControl
@onready var audio_control: AudioStreamPlayer2D = $AudioControl
@onready var audio_uncontrol: AudioStreamPlayer2D = $AudioUncontrol
@onready var animation_tree: AnimationTree = $AnimationTree

var can_move := true

var heart_position_right := Vector2(32,0)
var heart_position_bottom := Vector2(0,32)
var heart_position_left := Vector2(-32,0)
var heart_position_top := Vector2(0,-32)

var obstacle : Node = null


func _ready():
	# Spieler korrekt auf Grid ausrichten
	target_position = position.snapped(GRID_SIZE / 2)
	position = target_position
	animation_tree.get("parameters/playback").travel("Idle")


func _process(delta):
	move(delta)
	update_heart_visibility()


func _unhandled_input(event):
	if not event.is_pressed():
		return
		
	var direction := Vector2.ZERO
	
	if event.is_action_pressed("ui_cancel"):
			SceneSwitcher.go_to_settings()
	
	if can_move:
		# Bewegungsrichtungen (directional input)
		if event.is_action_pressed("Player_Up"):
			direction = Vector2.UP
		elif event.is_action_pressed("Player_Down"):
			direction = Vector2.DOWN
		elif event.is_action_pressed("Player_Left"):
			direction = Vector2.LEFT
		elif event.is_action_pressed("Player_Right"):
			direction = Vector2.RIGHT

		# Interaktionsbutton
		elif event.is_action_pressed("Interact"):
			if not is_moving:
				possess_or_unpossess_creature()
		
		animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
		if currently_possessed_creature:
			currently_possessed_creature.animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)

		# Bewegungsversuch oder Puffern
		if direction != Vector2.ZERO:
			if is_moving:
				buffered_direction = direction
			else:
				try_move(direction)
	else:
		# Szenewechsel durch Tastatur, Maus oder Gamepad
		
		if event.is_action_pressed("ui_accept"):# or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) :
			SceneSwitcher.go_to_next_level()


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
		spawn_trail(position)
		target_position = new_pos
		set_is_moving(true)
		return
		
	# Objekt vorhanden, prüfen ob pushable
	try_push_and_move(result, new_pos, direction, space_state)


func merge_if_possible(direction : Vector2) -> bool:
	if currently_possessed_creature != null:
		match direction:
			Vector2(1.0, 0.0): # right
				return await _merge(Vector2(64,0), currently_possessed_creature.neighbor_right)
			Vector2(0.0, 1.0): # bottom
				return await _merge(Vector2(0,64), currently_possessed_creature.neighbor_bottom)
			Vector2(-1.0, 0.0): # left
				return await _merge(Vector2(-64,0), currently_possessed_creature.neighbor_left)
			Vector2(0.0, -1.0): # top
				return await _merge(Vector2(0,-64), currently_possessed_creature.neighbor_top)
	return false


func _merge(direction : Vector2, neighbor : Creature):
	if neighbor != null:
		if currently_possessed_creature.can_merge_with(neighbor):
			var spawn_position = currently_possessed_creature.position + direction
			var merged_creature = get_tree().get_first_node_in_group("MergedCreature")
			if merged_creature and merged_creature is MergedCreature:
				merged_creature.position = spawn_position
				merged_creature.visible = false  # ← erst mal verstecken
				await get_tree().create_timer(0.1).timeout # creatures verschwinden und merged_creature taucht erst nach 0.1 sekunden
				currently_possessed_creature.shrink()
				neighbor.shrink()
				merged_creature.visible = true
				merged_creature.appear()
			can_move = false
			return true
	return false


func try_push_and_move(object_to_push, new_pos, direction, space_state):
	# Objekt vorhanden, prüfen ob pushable
	var obj = object_to_push[0].collider
	if not obj.is_in_group("pushable"):
		return

	if currently_possessed_creature == null:
		spawn_trail(position)
		target_position = new_pos
		set_is_moving(true)
		return
	
	# Ziel hinter dem pushable prüfen
	var push_target = new_pos + direction * GRID_SIZE
	var push_query := PhysicsPointQueryParameters2D.new()
	push_query.position = push_target
	push_query.collision_mask = 3
	var push_result = space_state.intersect_point(push_query, 1)

	# Falls frei, push ausführen
	if push_result.is_empty() and obj.push(direction):
		target_position = new_pos
		set_is_moving(true)
	else:
		buffered_direction = Vector2.ZERO


func set_is_moving(value: bool):
	is_moving = value

	if value:
		# Sound NUR EINMAL pro Tile-Bewegung abspielen
		audio_stream_player_2d.stop()
		audio_stream_player_2d.play()

		# Besessene Kreatur mitziehen lassen
		if currently_possessed_creature:
			possessed_creature_until_next_tile = currently_possessed_creature
	else:
		possessed_creature_until_next_tile = null


func possess_or_unpossess_creature():
	if currently_possessed_creature:
		# Unpossess: Sichtbarkeit zurücksetzen
		if is_instance_valid(currently_possessed_creature):
			currently_possessed_creature.border.visible = false

		currently_possessed_creature = null
		label_press_f_to_control.visible = true
		animated_sprite_2d.modulate = Color(1, 1, 1, 0.8)
		audio_uncontrol.play()

	else:
		# Possess: Übernehmen und sofort synchronisieren
		if hovering_over and hovering_over is Creature:
			currently_possessed_creature = hovering_over
			label_press_f_to_control.visible = false
			currently_possessed_creature.border.visible = true
			animated_sprite_2d.modulate = Color(1, 1, 1, 0)
			audio_control.play()

			# Position sofort synchronisieren
			currently_possessed_creature.position = target_position
			currently_possessed_creature.target_position = target_position

			possessed_creature_until_next_tile = currently_possessed_creature
	if not currently_possessed_creature:
		possessed_creature_until_next_tile = null


func _on_creature_detected(body: Node) -> void:
	if body is Creature:
		if currently_possessed_creature == null:
			hovering_over = body
			label_press_f_to_control.visible = true
		else:
			# Merge Möglichkeit eröffnen
			pass


func _on_creature_undetected(body: Node) -> void:
	if body is Creature and hovering_over == body:
		hovering_over = null
		label_press_f_to_control.visible = false


func spawn_trail(input_position: Vector2):
	var trail = trail_scene.instantiate()
	get_tree().current_scene.add_child(trail)
	trail.global_position = input_position
	trail.restart()	


func update_heart_visibility():
	# Wenn keine Kreatur gerade besessen ist → Herz aus
	if currently_possessed_creature == null:
		heart.visible = false
		return

	# Checke alle 4 Richtungen
	var c := currently_possessed_creature

	if c.neighbor_right and c.can_merge_with(c.neighbor_right):
		heart.position = self.position + heart_position_right
		heart.visible = true
		return

	if c.neighbor_bottom and c.can_merge_with(c.neighbor_bottom):
		heart.position = self.position + heart_position_bottom
		heart.visible = true
		return

	if c.neighbor_left and c.can_merge_with(c.neighbor_left):
		heart.position = self.position + heart_position_left
		heart.visible = true
		return

	if c.neighbor_top and c.can_merge_with(c.neighbor_top):
		heart.position = self.position + heart_position_top
		heart.visible = true
		return

	# Kein passender Nachbar gefunden → Herz aus
	heart.visible = false
