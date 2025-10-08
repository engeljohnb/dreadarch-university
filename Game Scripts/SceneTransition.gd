extends Node2D

signal scene_changed()
signal won()
var current_scene_name = "WelcomeMenu"
var prev_scene_name = ""
var current_scene_path = "res://UI/WelcomeMenu.tscn"
var player_start_position : Vector2
var by_door = false
var by_outside_door = false
var by_ladder = false
var ladder_direction = "Up"
var climb_cutscene = {}
var outdoor_light_progress = 0.0

func change_scene(scene_path, _player_start_pos = null, _by_door = false, _by_outside_door = false, _by_ladder = false, _ladder_direction = "Up"):
	prev_scene_name = current_scene_name
	current_scene_path = scene_path
	ladder_direction = _ladder_direction
	by_door = _by_door
	by_ladder = _by_ladder
	by_outside_door = _by_outside_door
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
