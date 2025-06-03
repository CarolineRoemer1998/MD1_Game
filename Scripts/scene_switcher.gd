extends Node

var current_scene = null
var current_level = 1
var levelCount = 2
func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func switch_scene(res_path):
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path):
	current_scene.free()
	var new_scene = load(res_path)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func go_to_next_level():
	var nextLevel = current_level + 1
	if nextLevel <= levelCount:
		switch_scene("res://Scenes/Level"+ str(nextLevel) +".tscn")
		current_level = nextLevel
	else:
		switch_scene("res://Scenes/Menu/MainMenu.tscn")
