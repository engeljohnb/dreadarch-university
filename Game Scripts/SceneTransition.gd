extends Node2D

signal new_scene()
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

func player_is_above_ground():
	return current_scene_name.contains("00-")
func entering_or_leaving_underground():
	var entering_underground = current_scene_name.contains("01-") and prev_scene_name.contains("00-")
	var leaving_undergound = current_scene_name.contains("00-") and prev_scene_name.contains("01-")
	return entering_underground or leaving_undergound
func scene_changed():
	return current_scene_name != prev_scene_name
func enter_scene(scene_path, _player_start_pos = null, _by_door = false, _by_outside_door = false, _by_ladder = false, _ladder_direction = "Up"):
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
	new_scene.emit()
	
func win():
	won.emit()
