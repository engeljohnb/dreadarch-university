extends Node2D

signal scene_changed()
signal won()
var current_scene_name = "res://UI/WelcomeMenu.tscn"
var player_start_position : Vector2
var by_door = false

func change_scene(scene_name, _player_start_pos = null, _by_door = false):
	current_scene_name = scene_name
	by_door = _by_door
	var instance = load(current_scene_name).instantiate()
	if _player_start_pos:
		player_start_position = _player_start_pos
	elif "player_start_position" in instance:
		player_start_position = instance.player_start_position
	instance.queue_free()
	scene_changed.emit()
	
func win():
	won.emit()
