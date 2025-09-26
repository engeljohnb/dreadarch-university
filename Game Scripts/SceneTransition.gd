extends Node2D

signal scene_changed()
signal won()
var current_scene_name = "WelcomeMenu"
var prev_scene_name = ""
var current_scene_path = "res://UI/WelcomeMenu.tscn"
var player_start_position : Vector2
var by_door = false

func change_scene(scene_path, _player_start_pos = null, _by_door = false):
	prev_scene_name = current_scene_name
	current_scene_path = scene_path
	by_door = _by_door
	var instance = load(scene_path).instantiate()
	current_scene_name = instance.name
	if _player_start_pos != null:
		player_start_position = _player_start_pos
	elif "player_start_position" in instance:
		player_start_position = instance.player_start_position
	instance.queue_free()
	scene_changed.emit()
	
func win():
	won.emit()
