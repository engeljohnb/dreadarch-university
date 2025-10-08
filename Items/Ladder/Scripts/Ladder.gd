extends Area2D
@export var next_start_position : Vector2
@export var next_scene : String
@export var direction : String

var player_entered = false
var player : CharacterBody2D
var timer = 0.0
var safe_to_climb = false

func on_body_entered(body):
	if not safe_to_climb:
		return
	if body.is_in_group("Player"):
		if not body.in_cutscene:
			player_entered = true
			player = body
			var _direction = "Up"
			var arriving = false
			var _position = global_position
			var start_pos = player.global_position
			player.play_climb_cutscene(0.0,
			{"direction":_direction, "arriving":arriving,"position":_position,"start_pos":start_pos})
		
func _ready():
	body_entered.connect(on_body_entered)

func _process(_delta):
	#This is because the player may collide with the ladder before the player's position is update,
	# Causing the player to immediately climb no matter where the start position is supposed to be
	if not safe_to_climb:
		timer += _delta
		if timer >= 0.25:
			safe_to_climb = true
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		if not player.in_cutscene:
			SceneTransition.change_scene(next_scene, next_start_position, false, false, true, "Up")
