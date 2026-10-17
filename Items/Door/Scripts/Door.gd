extends Area2D
class_name Door

@export var next_scene : String
@export var next_start_position : Vector2
@export var should_open_next_door : bool = false
@export var direction = "North"


var player_entered = false
var player : CharacterBody2D
func start_transition(pos = global_position):
		player.play_door_cutscene(0.0, pos, direction)
		player_entered = true
