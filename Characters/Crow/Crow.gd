extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var search_area = $SearchArea
@onready var search_ray = $SearchRay
@onready var path = $Path2D

const SPEED = 100.0

var player
var facing = Vector2(0,1)
var direction_changed = false
var prev_position = position
var attacking = false
var aggrod = false
var moving = false
var _projectile = load("res://Characters/Crow/Projectile/CrowProjectile.tscn")

func _ready():
	search_area.player_nearby.connect(_on_player_nearby)

func reset_attack():
	attacking = false

func launch_projectile():
	var projectile = _projectile.instantiate()
	add_child(projectile)
	projectile.launch(facing)
	
func _on_player_nearby(_player):
	aggrod = true
	player = _player
	
func update_movement(delta):
	if aggrod:
		if attacking:
			position = prev_position
		else:
			var to_player = (player.global_position - global_position).normalized()
			position += (SPEED*delta) * to_player
	else:
		var next = path.get_next_point(position, delta, SPEED)
		position += (SPEED*delta) * (next - position).normalized()
	
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
	
func _process(_delta):
	update_movement(_delta)
	update_direction()
	prev_position = position
	if aggrod:
		update_attack()
	update_animation_blend_positions()
