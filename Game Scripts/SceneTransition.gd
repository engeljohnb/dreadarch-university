extends Node2D

signal scene_changed()
signal won()
var current_scene_name = "res://UI/WelcomeMenu.tscn"
var player_start_position : Vector2

func change_scene(scene_name, _player_start_pos = null):
	current_scene_name = scene_name
	var instance = load(current_scene_name).instantiate()
	if _player_start_pos:
		player_start_position = _player_start_pos
	elif "player_start_position" in instance:
		player_start_position = instance.player_start_position
	scene_changed.emit()
	
func win():
	won.emit()
