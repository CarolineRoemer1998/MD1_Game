extends Node

var current_scene = null
var current_level = 0
var levelCount = 4
var paused_scene = null  # T o store the paused scene
var is_paused = false   # To track if we're in a paused state

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func switch_scene(res_path, pause_current=false):
	call_deferred("_deferred_switch_scene", res_path, pause_current)

func _deferred_switch_scene(res_path, pause_current=false):
	if pause_current:
		# Instead of freeing current scene, just hide it and store reference
		current_scene.hide()
		paused_scene = current_scene
		is_paused = true
		get_tree().paused = true
	else:
		# If we're returning from a paused scene, free the paused scene
		if is_paused:
			paused_scene.free()
			is_paused = false
			get_tree().paused = false
		# Otherwise free current scene normally
		elif current_scene:
			current_scene.free()
	
	var new_scene = load(res_path)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func go_to_next_level():
	if current_level == levelCount:
		switch_scene("res://Scenes/Menu/credit_scene.tscn")
		return
	var nextLevel = current_level + 1
	if nextLevel <= levelCount:
		switch_scene("res://Scenes/Level"+ str(nextLevel) +".tscn")
		current_level = nextLevel
	else:
		go_to_main_menu()

func go_to_current_level():
	if current_level > 0 and current_level <= levelCount:
		switch_scene("res://Scenes/Level"+ str(current_level) +".tscn")
	else:
		go_to_main_menu()

func reload_level():
	if current_scene:
		current_scene.queue_free()

	if current_level > 0 and current_level <= levelCount:
		switch_scene("res://Scenes/Level" + str(current_level) + ".tscn")
	else:
		go_to_main_menu()
	print("scene reloaded")


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
