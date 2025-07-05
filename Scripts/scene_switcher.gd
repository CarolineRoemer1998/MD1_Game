extends Node

@onready var fade_scene = preload("res://Scenes/Menu/fade.tscn")
var fade_node = null
var fade_animation = null
var level_folder = "res://Scenes/Level/"

var current_scene = null
var current_level = 0
var levelCount = 0
var paused_scene = null  # T o store the paused scene
var is_paused = false   # To track if we're in a paused state

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	levelCount = get_level_count_from_folder(level_folder)
	print("Found %d levels in %s" % [levelCount, level_folder])
	levelCount = 6
	
func switch_scene(res_path, pause_current=false):
	call_deferred("_deferred_switch_scene", res_path, pause_current)

func _deferred_switch_scene(res_path, pause_current=false):
	# Handle pause or regular cleanup
	if pause_current:
		current_scene.hide()
		paused_scene = current_scene
		is_paused = true
		get_tree().paused = true
	else:
		if is_paused:
			paused_scene.free()
			is_paused = false
			get_tree().paused = false
		elif current_scene:
			current_scene.free()

	# Load and instantiate the new scene first
	var new_scene = load(res_path).instantiate()
	current_scene = new_scene
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

	# Inject fade if it's a level scene
	if res_path.contains("/Scenes/Level/Level"):
		if not fade_node:
			fade_node = fade_scene.instantiate()
		current_scene.add_child(fade_node)  # Important: add it to new scene, not root
		fade_animation = fade_node.get_node("AnimationPlayer")
		fade_animation.play("fade")
		await fade_animation.animation_finished

func switch_to_level(levelID: int):
	switch_scene(level_folder + "Level"+ str(levelID) +".tscn")

func go_to_next_level():
	if current_level == levelCount:
		current_level = 0
		switch_scene("res://Scenes/Menu/credit_scene.tscn")
		return
	var nextLevel = current_level + 1
	if nextLevel <= levelCount:
		switch_to_level(nextLevel)
		current_level = nextLevel
	else:
		go_to_main_menu()

func go_to_current_level():
	if current_level > 0 and current_level <= levelCount:
		switch_to_level(current_level)
	else:
		go_to_main_menu()

func reload_level():
	if current_scene:
		current_scene.queue_free()

	if current_level > 0 and current_level <= levelCount:
		switch_to_level(current_level)
	else:
		go_to_main_menu()


# New functions for settings
func go_to_settings():
	switch_scene("res://Scenes/Menu/InGameSettings.tscn", true)

func go_to_main_menu(ending_game: bool = false):
	if ending_game:
		current_scene.queue_free()
	current_level = 0
	switch_scene("res://Scenes/Menu/MainMenu.tscn")


func return_from_scene():
	if is_paused and paused_scene:
		# Free the settings scene and restore the paused scene
		current_scene.queue_free()
		paused_scene.show()
		current_scene = paused_scene
		is_paused = false
		get_tree().paused = false
		get_tree().current_scene = current_scene
	else:
		# Fallback if something went wrong
		go_to_current_level()

func set_curent_level(level_number: int):
	if level_number >= 0 and level_number <= levelCount:
		current_level = level_number
	else:
		current_level = 0

func get_level_count_from_folder(folder_path: String) -> int:
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Failed to open folder: " + folder_path)
		return 0
	
	var count = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			count += 1
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return count
