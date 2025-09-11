extends Area2D
@export var next_start_position : Vector2
@export var next_scene : String
@export var direction : String

var player_entered = false

func on_body_entered(body):
	if body.is_in_group("Player"):
		player_entered = true
		
		
func _ready():
	match direction:
		"Up":
			$AnimatedSprite2D.frame = 1
		"":
			$AnimatedSprite2D.frame = 0
	body_entered.connect(on_body_entered)

func _process(_delta):
	if player_entered:
		# Apparently calling this function right from on_body_entered breaks everything
		SceneTransition.change_scene(next_scene, next_start_position)
