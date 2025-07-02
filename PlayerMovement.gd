extends CharacterBody2D
class_name Player

const GRID_SIZE := Vector2(64, 64)
const MOVE_SPEED := 500.0
const ICE_MOVE_SPEED := 400.0

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
@onready var label_press_f_to_stop_control: Label = $LabelPressFToStopControl
@onready var audio_control: AudioStreamPlayer2D = $AudioControl
@onready var audio_uncontrol: AudioStreamPlayer2D = $AudioUncontrol
@onready var animation_tree: AnimationTree = $AnimationTree

# LAYER BITS
const WALL_AND_PLAYER_LAYER_BIT := 0
const CREATURE_LAYER_BIT := 1
const PUSHABLE_LAYER_BIT := 2
const DOOR_LAYER_BIT     := 3
const ICE_LAYER_BIT      := 5

var can_move := true

var heart_position_right := Vector2(32,0)
var heart_position_bottom := Vector2(0,32)
var heart_position_left := Vector2(-32,0)
var heart_position_top := Vector2(0,-32)

var obstacle : Node = null

var is_on_ice := false

var current_direction := Vector2(0,0)


func _ready():
	# Spieler korrekt auf Grid ausrichten
	target_position = position.snapped(GRID_SIZE / 2)
	position = target_position
	animation_tree.get("parameters/playback").travel("Idle")


func _process(delta):
	move(delta)
	update_heart_visibility()
	
		
	#var direction := Vector2.ZERO
	#
	#if Input.is_action_just_pressed("ui_cancel"):
			#SceneSwitcher.go_to_settings()
	##if event.is_action_pressed("Reload_Level"):
			##SceneSwitcher.reload_level()
	#
	#if can_move:
		## Bewegungsrichtungen (directional input)
		#if Input.is_action_just_pressed("Player_Up"):
			#direction = Vector2.UP
		#elif Input.is_action_just_pressed("Player_Down"):
			#direction = Vector2.DOWN
		#elif Input.is_action_just_pressed("Player_Left"):
			#direction = Vector2.LEFT
		#elif Input.is_action_just_pressed("Player_Right"):
			#direction = Vector2.RIGHT
#
		## Interaktionsbutton
		#elif Input.is_action_just_pressed("Interact"):
			#if not is_moving:
				#possess_or_unpossess_creature()
		#
		#animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
		#if currently_possessed_creature:
			#currently_possessed_creature.animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
#
		## Bewegungsversuch oder Puffern
		#if direction != Vector2.ZERO:
			#if is_moving:
				#buffered_direction = direction
			#else:
				#try_move(direction)
	#else:
		## Szenewechsel durch Tastatur, Maus oder Gamepad
		#
		#if Input.is_action_just_pressed("ui_accept"):# or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) :
			#SceneSwitcher.go_to_next_level()


func _unhandled_input(event):
	if not event.is_pressed():
		return
		
	var direction := Vector2.ZERO
	
	if event.is_action_pressed("ui_cancel"):
			SceneSwitcher.go_to_settings()
	#if event.is_action_pressed("Reload_Level"):
			#SceneSwitcher.reload_level()
	
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
		if is_on_ice and currently_possessed_creature:
			move_on_ice(delta)
	
				
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


func move_on_ice(delta):
	set_is_on_ice(target_position + current_direction * GRID_SIZE)
	#MOVE_SPEED = 400.0
	
	var block_mask = (1 << WALL_AND_PLAYER_LAYER_BIT) | (1 << DOOR_LAYER_BIT) | (1 << CREATURE_LAYER_BIT) | (1 << PUSHABLE_LAYER_BIT)
	var space = get_world_2d().direct_space_state
	var slide_end = target_position
	var result_block
	var result_ice
	
	var can_slide = true
	
	var next_collision = get_collision_on_tile(slide_end, 1 << PUSHABLE_LAYER_BIT)
	if next_collision.size() > 0:
		if next_collision[0].collider is Pushable:
			can_slide = false
			slide_end = slide_end - current_direction * GRID_SIZE
			return
	
	while can_slide:
		var next_pos = slide_end + current_direction * GRID_SIZE
		
		result_block = check_if_collides(next_pos, block_mask)
		result_ice = check_if_collides(next_pos, 1 << ICE_LAYER_BIT)
		
		if check_if_collides(next_pos, block_mask):
			break
			
		if not check_is_ice(next_pos):
			slide_end = next_pos
			break
				
		slide_end = next_pos
	
		
	if slide_end != target_position: #or not result_block.is_empty():
		target_position = slide_end
	#else:
		#target_position += current_direction * GRID_SIZE

func check_is_ice(pos: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 << ICE_LAYER_BIT
	var result = space.intersect_point(query, 1)
	return not result.is_empty()

func check_if_collides(position, layer_mask) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = layer_mask
	var result = space.intersect_point(query, 1)
	return not result.is_empty()

func get_collision_on_tile(position, layer_mask):
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = layer_mask
	return space.intersect_point(query, 1)


func try_move(direction: Vector2):
	var new_pos = target_position + direction * GRID_SIZE
	current_direction = direction
	var space_state = get_world_2d().direct_space_state
	
	set_is_on_ice(new_pos)
		
	merge_if_possible(direction)
	
	# Prüfen ob ein Objekt am Zielort ist
	var query := PhysicsPointQueryParameters2D.new()
	query.position = new_pos
	
	
	
	# Query für Pushables
	query.collision_mask = (1 << PUSHABLE_LAYER_BIT)
	var result_pushables = space_state.intersect_point(query, 1)
	
	# Query für Türen
	query.collision_mask = (1 << DOOR_LAYER_BIT)
	var result_doors = space_state.intersect_point(query, 1)
	
	# Query für Blockaden
	query.collision_mask = (1 << WALL_AND_PLAYER_LAYER_BIT)
	var result_wall = space_state.intersect_point(query, 1)
	
	# Kein Objekt: Bewegung frei
	if (result_pushables.is_empty() or currently_possessed_creature == null) and (result_doors.is_empty() or currently_possessed_creature == null) and result_wall.is_empty():
		spawn_trail(position)
		target_position = new_pos
		set_is_moving(true)
		return
	
	try_push_and_move(result_pushables, result_doors, result_wall, new_pos, direction, space_state)

func set_is_on_ice(new_pos) -> bool:
	var space_state = get_world_2d().direct_space_state
	var ice_query = PhysicsPointQueryParameters2D.new()
	ice_query.position = new_pos
	ice_query.collision_mask = 1 << ICE_LAYER_BIT
	ice_query.collide_with_bodies = true
	ice_query.collide_with_areas  = true
	is_on_ice = not space_state.intersect_point(ice_query, 1).is_empty()
	return is_on_ice

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

func try_push_and_move(pushable, door, wall, new_pos, direction, space_state):
	
	# Wand vor Spieler, keine Bewegung
	if pushable.is_empty() and door.is_empty() and not wall.is_empty():
		return
	
	# Spieler ist Geist und kann sich durch restliche Objekte durch bewegen
	if currently_possessed_creature == null:
		spawn_trail(position)
		target_position = new_pos
		set_is_moving(true)
		return
	
	# Tür vor Spieler
	if not door.is_empty():
		# Tür verschlossen, keine Bewegung
		if door[0].collider.door_is_closed:
			return
			
		# Tür offen
		elif not door[0].collider.door_is_closed:
			spawn_trail(position)
			target_position = new_pos
			set_is_moving(true)
			# Wenn Spieler kein Pushable durch die Tür schiebt, Funktion hier beenden
			if pushable.is_empty():
				return
	
	# Ziel hinter dem pushable prüfen
	var push_target = new_pos + direction * GRID_SIZE
	var push_query := PhysicsPointQueryParameters2D.new()
	push_query.position = push_target
	push_query.collision_mask = (1 << PUSHABLE_LAYER_BIT) | (1 << DOOR_LAYER_BIT) | (1 << WALL_AND_PLAYER_LAYER_BIT) | (1 << CREATURE_LAYER_BIT)
	var push_result = space_state.intersect_point(push_query, 1)
	
	for i in push_result:
		if i.collider is Door and not i.collider.door_is_closed:
			if pushable[0].collider.push(direction * GRID_SIZE):
				target_position = new_pos
				set_is_moving(true)
				return
		
	# Falls frei oder Tür die offen ist, push ausführen
	if push_result.is_empty():
		if pushable[0].collider.push(direction * GRID_SIZE):
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
		label_press_f_to_stop_control.visible = false
		animated_sprite_2d.modulate = Color(1, 1, 1, 0.8)
		audio_uncontrol.play()

	else:
		# Possess: Übernehmen und sofort synchronisieren
		if hovering_over and hovering_over is Creature:
			currently_possessed_creature = hovering_over
			label_press_f_to_control.visible = false
			label_press_f_to_stop_control.visible = true
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
