extends Area2D
@export var next_start_position : Vector2
@export var next_scene : String
@export var direction : String

var player_entered = false
var player : CharacterBody2D

func on_body_entered(body):
	if body.is_in_group("Player"):
		if not body.in_cutscene:
			player_entered = true
			player = body
			player.play_climb_cutscene(0.0, 
			{"direction":"Down", "position":global_position, "start_pos":player.global_position, "arriving":false})
		
func _ready():
	body_entered.connect(on_body_entered)

func _process(_delta):
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		if not player.in_cutscene:
			SceneTransition.change_scene(next_scene, next_start_position, false, false, true, "Down")
