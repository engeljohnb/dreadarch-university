extends RigidBody2D

var facing = Vector2(0,-1)
@onready var anim_player = $AnimationPlayer
@onready var fx_player = $FXPlayer
@onready var hitbox = $CollisionShape2D
@onready var launch_sprite = $"Launch Effect"

func _on_body_entered(body):
	if (body != get_parent()):
		queue_free()
	
func _ready():
	launch_sprite.modulate = Color(0.6, 0.0, 0.85, 1)
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

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
	anim_player.play(animation_name)
	fx_player.play(animation_name)
