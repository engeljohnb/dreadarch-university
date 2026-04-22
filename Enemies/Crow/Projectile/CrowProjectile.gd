extends Weapon

var facing = Vector2(0,-1)
var launch_velocity = facing
var countdown = 2.5
@onready var anim_player = $AnimationPlayer
@onready var fx_player = $FXPlayer
@onready var hitbox = $CollisionShape2D
@onready var launch_sprite = $"Launch Effect"
@onready var outline_sprite = $"Launch Effect/Launch Effect Outline"
@onready var _light = load("res://Enemies/Crow/Projectile/CrowProjectileLight.tscn")
var _by_player = false
var dead = false
	
func _on_body_entered(_body):
	if _body != get_parent():
		$DeathSound.play()
		death()
	
func _ready():
	visible = false
	launch_sprite.visible = false
	outline_sprite.visible = false
	outline_sprite.modulate = Color(0,0,0)
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


func launch(direction, by_player = false):
	_by_player = by_player
	var animation_name = get_animation_name(direction)
	var cardinal_direction = name_to_vector(animation_name)
	var light = _light.instantiate()
	light.energy = 0.5
	add_child(light)
	anim_player.play(animation_name)
	fx_player.play(animation_name)
	position += 10*cardinal_direction
	if animation_name == "Down":
		position.x -= 15
		light.rotation -= PI/2.0
		#light.position.x -= 25
		light.position.y -= 400
	if (animation_name == "Left"):
		position += 15*cardinal_direction
		#light.rotation += 2.0*PI
		light.position -= 400*cardinal_direction
	if (animation_name == "Right"):
		position += 15*cardinal_direction
		light.rotation += PI
		light.position -= 400*cardinal_direction
	if (animation_name == "Up"):
		light.rotation += PI/2.0
		position.y -= 20
		position.x += 10
		light.position.y += 400
	launch_velocity = cardinal_direction * 350

func _physics_process(_delta):
	countdown -= _delta
	if countdown <= 0.0:
		death()
	if dead:
		death()
	else:
		global_position += launch_velocity*_delta
	if not visible:
		visible = true
		launch_sprite.visible = true
		outline_sprite.visible = true
