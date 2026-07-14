extends Weapon

var facing = Vector2(0,-1)
var launch_velocity = facing
var countdown = 20.0
@onready var anim_player = $AnimationPlayer
@onready var fx_player = $FXPlayer
@onready var hitbox = $CollisionShape2D
@onready var launch_sprite = $"Launch Effect"
@onready var outline_sprite = $"Launch Effect/Launch Effect Outline"
@onready var _light = preload("res://Weapons/Projectiles/Talons/CrowProjectileLight.tscn")
var dead = false
	
func _on_body_entered(_body):
	if _body is Weapon:
		if _body.type == type:
			return
	if _body != parent:
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
		_name:
			Error.error("name_to_vector error: name doesn't correspond with a direction" + _name)

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

func activate(direction):
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
		light.position.y -= 400
	if (animation_name == "Left"):
		position += 15*cardinal_direction
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
	rotation += cardinal_direction.angle_to(direction)
	launch_velocity = direction * 450.0
	$SoundComponent.play_sound("Fire")

func _process(_delta):
	countdown -= _delta
	if countdown <= 0.0:
		death()
		return
	if dead:
		death()
		return
	else:
		global_position += launch_velocity*_delta
	if not visible:
		visible = true
		launch_sprite.visible = true
		outline_sprite.visible = true
