extends Node2D

signal scene_changed()
signal won()
var current_scene_name = "res://UI/WelcomeMenu.tscn"
var player_start_pos = Vector2(500,500)
var player_newgame_position : Vector2

func change_scene(scene_name, _player_start_pos = player_start_pos):
	current_scene_name = scene_name
	player_start_pos = _player_start_pos
	var instance = load(current_scene_name).instantiate()
	var start_pos = null
	if "player_start_position" in instance:
		start_pos = instance.player_start_position
	if start_pos:
		print(start_pos)
		player_newgame_position = start_pos
	scene_changed.emit()
	
func win():
	won.emit()
