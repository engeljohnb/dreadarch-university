extends Node2D
var timer = 0.0

func _ready():
	for child in get_children():
		if child is AnimatedSprite2D:
			child.frame = randi() % child.sprite_frames.get_frame_count("default")
			child.play("default")
	
func _process(_delta):
	timer += _delta
	$PointLight2D.energy = 1.5 + (sin(timer*20.0)/5.0)
	if timer >= 60.0:
		timer = 0.0
