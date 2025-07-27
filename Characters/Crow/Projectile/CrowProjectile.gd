extends RigidBody2D

var facing = Vector2(0,-1)
@onready var anim_player = $AnimationPlayer

func name_to_vector(_name):
	match _name:
		"Left":
			return Vector2(-1,0)
		"Right":
			return Vector2(1,0)
		"Up":
			return Vector2(0,-1)
		"Down":
			return Vector2(0,1)
	push_error("name_to_vector error: name doesn't correspond with a direction", _name)

func get_animation_name(direction):
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
			
func launch(direction):
	var animation_name = get_animation_name(direction)
	var cardinal_direction = name_to_vector(animation_name)
	add_constant_force(cardinal_direction * 800)
	position += 10*cardinal_direction
	if animation_name == "Down":
		position.x -= 15
	if (animation_name == "Left") or animation_name == "Right":
		position += 15*cardinal_direction
	if (animation_name == "Up"):
		position.y -= 20
		position.x += 10
	anim_player.play(get_animation_name(direction))
