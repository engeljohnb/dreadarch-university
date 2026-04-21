extends RigidBody2D

var facing = Vector2(0,-1)
var launch_velocity = facing
var countdown = 2.5
@onready var anim_player = $AnimationPlayer
@onready var fx_player = $FXPlayer
@onready var hitbox = $CollisionShape2D
@onready var launch_sprite = $"Launch Effect"
@onready var outline_sprite = $"Launch Effect/Launch Effect Outline"
@onready var deathlight = $DeathLight
@onready var _light = load("res://Enemies/Crow/Projectile/CrowProjectileLight.tscn")
var _by_player = false
var cutscene_timer = 0.0
var death_cutscene_duration = 0.33
var dead = false
var parent_hitbox : EnemyHitbox

# This projectile shouldn't trigger the hitbox of the actor that created it, 
#   but since projectiles are usually siblings instead of children,
#   it's not easy to tell who created it. It needs to be
#   set manually by the creator. It's the best I could think of
func set_parent_hitbox(_parent_hitbox : EnemyHitbox):
	parent_hitbox = _parent_hitbox

func death():
	dead = true
	$AnimatedSprite2D.visible = false
	$"Launch Effect".visible = false
	deathlight.visible = true
	hitbox.set_deferred("disabled", true)
	
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
	if parent_hitbox != null:
		parent_hitbox.ignore.append(self)

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

func play_death_cutscene(delta):
		deathlight.modulate = Color(1,0,0,)
		cutscene_timer += delta
		var cutscene_percent = cutscene_timer/death_cutscene_duration
		deathlight.energy = 1.0/cutscene_percent
		if cutscene_timer >= death_cutscene_duration:
			queue_free()

func launch(direction, by_player = false):
	#print("Now Launching: " + name)
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
		play_death_cutscene(_delta)
	else:
		global_position += launch_velocity*_delta
	if not visible:
		visible = true
		launch_sprite.visible = true
		outline_sprite.visible = true
