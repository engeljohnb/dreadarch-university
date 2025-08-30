extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var blinker = $Blinker
@onready var lifebar = $Lifebar

const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const SPEED = 300.0

var _attack_fx = load("res://Characters/Player/PlayerAttackFX.tscn")
var attack_fx = null
var facing = Vector2()
var direction_changed = false
var moving = false
var knife_equipped = true
var attacking = false

func reset_direction_changed():
	direction_changed = false

func update_direction():
	direction_changed = false
	if moving:
		if (Input.is_action_just_released("Left")
		or Input.is_action_just_released("Right")
		or Input.is_action_just_released("Up")
		or Input.is_action_just_released("Down")
		or Input.is_action_just_pressed("Left")
		or Input.is_action_just_pressed("Right")
		or Input.is_action_just_pressed("Up")
		or Input.is_action_just_pressed("Down")):
			direction_changed = true

	var movement_direction = Vector2()
	if Input.is_action_pressed("Left"):
		movement_direction += LEFT
	if Input.is_action_pressed("Right"):
		movement_direction += RIGHT
	if Input.is_action_pressed("Up"):
		movement_direction += UP
	if Input.is_action_pressed("Down"):
		movement_direction += DOWN
	movement_direction = movement_direction.normalized()
	
	if movement_direction.is_zero_approx():
		moving = false
	else:
		moving = true
		facing = movement_direction
		
func update_animation_blend_positions():
	anim_tree.set("parameters/Walk/Walk/blend_position", facing)
	anim_tree.set("parameters/Walk/Walk Knife/blend_position", facing)
	anim_tree.set("parameters/Attack/blend_position", facing)
	anim_tree.set("parameters/Idle/Idle/blend_position", facing)
	anim_tree.set("parameters/Idle/Idle Knife/blend_position", facing)
	
func update_attack_state():
	if !knife_equipped:
		return
	if attacking and (not attack_fx):
		attacking = false
		return
	if Input.is_action_just_pressed("Attack") and (not attacking):
		attacking = true
		attack_fx = _attack_fx.instantiate()
		attack_fx.change_direction(facing)
		add_child(attack_fx)

func reset_attack_state():
	remove_child(attack_fx)
	attack_fx = null
	attacking = false
	
func update_position(delta):
	if attacking:
		return
	if moving:
		position += SPEED * facing * delta
		move_and_slide()
	
func death():
	queue_free()

func on_hit(_body):
	# Check for i-frames
	if not blinker.blinking:
		lifebar.on_hit()
		blinker.blink(0.5)
	
func on_blinker_flip(state):
	if state:
		set_modulate(Color(3, 3, 3))
	else:
		set_modulate(Color(1,1,1))

func _ready():
	hitbox.hit.connect(on_hit)
	blinker.flip.connect(on_blinker_flip)
	lifebar.dead.connect(death)
	lifebar.set_life_total(7)
	lifebar.top_level = true
	lifebar.position = Vector2(40,40)
	
func _process(delta):
	update_direction()
	update_attack_state()
	update_position(delta)
	update_animation_blend_positions()
