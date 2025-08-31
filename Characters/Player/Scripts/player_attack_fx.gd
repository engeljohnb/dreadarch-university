extends StaticBody2D

@onready var main_sprite = $AnimatedSprite2D
@onready var outline_sprite = $OutlineSprite

func _ready():
	$AnimatedSprite2D.animation_finished.connect(queue_free)
	set_modulate(Color(0.7,0.4,0.3,0.8))
	$OutlineSprite.set_modulate(Color(0,0,0))
	$OutlineSprite.z_index = -1
	$OutlineSprite.position.x -= 10
	
func vec_to_name(direction):
	var x = direction.x
	var y = direction.y
	if (abs(x) > abs(y)):
		if (x < 0):
			return "Left"
		else:
			return "Right"
	else:
		if (y < 0):
			return "Up"
		else:
			return "Down"

func change_direction(facing):
	var direction_name = vec_to_name(facing)
	match direction_name:
		"Left":
			position.x -= 40
			scale.x = -scale.x
		"Up":
			rotate(-PI/2.0)
			position.y -= 40
		"Down":
			rotate(PI/2.0)
			scale.y = -scale.y
			position.y += 40
		"Right":
			position.x += 40
	$AnimatedSprite2D.play("default")
	$OutlineSprite.play("default")
	
