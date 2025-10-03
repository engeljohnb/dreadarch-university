extends Area2D

var player_entered = false
var player = null
@export var next_scene : String
@export var next_start_position : Vector2
@export var should_open_next_door : bool = false
func on_body_entered(body):
	if body.is_in_group("Player"):
		body.play_outside_door_cutscene(0.0)
		player_entered = true
		player = body
	
func _ready():
	body_entered.connect(on_body_entered)

func _process(_delta):
	if player_entered:
		if not player.in_cutscene:
			if should_open_next_door:
				SceneTransition.change_scene(next_scene, next_start_position, true)
			else:
				SceneTransition.change_scene(next_scene, next_start_position)
