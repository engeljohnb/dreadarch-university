extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var search_area = $SearchArea
@onready var search_ray = $SearchRay
@onready var path = $Path2D
@onready var hitbox = $Hitbox
@onready var blinker = $Blinker
@onready var animation_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
const SPEED = 100.0

var player
var knockback_direction = Vector2()
var knockback_speed = 0.0
var facing = Vector2(0,1)
var direction_changed = false
var prev_position = position
var attacking = false
var aggrod = false
var moving = false
var _projectile = load("res://Characters/Crow/Projectile/CrowProjectile.tscn")
var life = 3
var in_cutscene = false
var current_cutscene = null
var cutscene_timer = 0.0
var cutscene_duration = 0.0
var dead

func play_death_cutscene(delta):
	in_cutscene = true
	cutscene_duration = 2.66
	current_cutscene = play_death_cutscene
	var deathlight = $DeathLight
	if (delta == 0.0):
		$CollisionShape2D.set_deferred("disabled", true)
		if (get_node_or_null("AnimationPlayer")):
			animation_player.queue_free()
		if (get_node_or_null("AnimationTree")):
			$AnimationTree.queue_free()
		deathlight.visible = true
		deathlight.energy = 1.0
		deathlight.modulate = Color(1,0,0,)
		sprite.visible = false
	else:
		deathlight.modulate = Color(1,0,0,)
		cutscene_timer += delta
		var cutscene_percent = 2.66/cutscene_timer
		deathlight.energy = cutscene_percent*0.175
		if cutscene_timer >= cutscene_duration:
			queue_free()
	
	
func death():
	play_death_cutscene(0.0)

func on_blinker_flip(state):
	if state:
		set_modulate(Color(1.4, 1.4, 1.4))
	else:
		set_modulate(Color(1,1,1))

func on_hit(_body):
	if (not blinker.blinking):
		knockback_direction = (_body.get_parent().global_position - global_position).normalized()
		knockback_speed = 400.0
		blinker.blink(0.5)
		life -= 1
		if life <= 0:
			death()

func _ready():
	search_area.player_nearby.connect(_on_player_nearby)
	hitbox.hit.connect(on_hit)
	blinker.flip.connect(on_blinker_flip)

func reset_attack():
	attacking = false

func launch_projectile():
	var projectile = _projectile.instantiate()
	hitbox.my_weapon = projectile
	# Add as sibling instead of child so Crow's movement doesn't
	# affect the projectile
	projectile.global_position = position
	add_sibling(projectile)
	projectile.launch(facing)
	
func _on_player_nearby(_player):
	aggrod = true
	player = _player
	
func update_movement(delta):
	if not blinker.blinking:
		if aggrod:
			if attacking:
				position = prev_position
			else:
				var to_player = (player.global_position - global_position).normalized()
				position += (SPEED*delta) * to_player
		else:
			var next = path.get_next_point(position, delta, SPEED)
			position += (SPEED*delta) * (next - position).normalized()
	move_and_slide()

func update_direction():
	direction_changed = false
	var prev_facing = facing
	facing = (position - prev_position).normalized()
	if (abs(facing.angle_to(prev_facing)) > 0.02):
		direction_changed = true
		# For some reason the AnimationTree won't go to the next animation
		# if the current animation is looped. So I have to do it manually here.
		if not aggrod:
			var state_machine = anim_tree["parameters/playback"]
			state_machine.travel("Walk/Transition")
	if facing.is_zero_approx() or attacking:
		facing = prev_facing
		moving = false
	else:
		moving = true
	search_ray.target_position = facing * 200
	
func update_animation_blend_positions():
	anim_tree.set("parameters/Walk/Walking/blend_position", facing)
	anim_tree.set("parameters/Walk/Transition/blend_position", facing)
	anim_tree.set("parameters/Attack/blend_position", facing)
	anim_tree.set("parameters/Idle/blend_position", facing)
	anim_tree.set("parameters/Prepare Attack/blend_position", facing)
	
func update_attack():
	if search_ray.is_colliding():
		if search_ray.get_collider() == player:
			# This is set to false with an animation in the AnimationTree state machine. 
			# I know it's stupid but it's the easiest way to set it to false exactly at the end of 
			# the animation that I can think of.
			attacking = true
			# For some reason the AnimationTree won't go to the next animation
			# if the current animation is looped. So I have to do it manually here.
			var state_machine = anim_tree["parameters/playback"]
			state_machine.travel("Attack")
	
func _physics_process(_delta):
	if blinker.blinking:
		position += -(knockback_direction*knockback_speed*_delta)
	knockback_speed -= 10.0
	if knockback_speed < 0.0:
		knockback_speed = 0.0
	
func _process(_delta):
	if not in_cutscene:
		update_movement(_delta)
		update_direction()
		prev_position = position
		if aggrod:
			update_attack()
		update_animation_blend_positions()
	else:
		if current_cutscene:
			current_cutscene.call(_delta)
