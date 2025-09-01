extends Node2D

signal scene_changed()
signal won()
var current_scene_name = "res://UI/WelcomeMenu.tscn"
var player_start_pos = Vector2()

func change_scene(scene_name, _player_start_pos = Vector2()):
	current_scene_name = scene_name
	player_start_pos = _player_start_pos
	scene_changed.emit()
	
func win():
	won.emit()
