extends CharacterBody2D

signal dead()
signal lost_life(damage)
signal gained_life(life)
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var blinker = $Blinker

const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const SPEED = 300.0

var life = 3
var total_life = 3
var _attack_fx = load("res://Characters/Player/PlayerAttackFX.tscn")
var attack_fx = null
var facing = Vector2(0,1)
var direction_changed = false
var moving = false
var knife_equipped = true
var attacking = false

var direction_priority

func reset_direction_changed():
	direction_changed = false

func update_direction():
	direction_changed = false
	if moving:
		if Input.is_action_just_pressed("Left"):
			direction_priority = "Left"
			direction_changed = true
		if Input.is_action_just_pressed("Right"):
			direction_priority = "Right"
			direction_changed = true
		if Input.is_action_just_pressed("Up"):
			direction_priority = "Up"
			direction_changed = true
		if Input.is_action_just_pressed("Down"):
			direction_priority = "Down"
			direction_changed = true
		if (Input.is_action_just_released("Left")
		or Input.is_action_just_released("Right")
		or Input.is_action_just_released("Up")
		or Input.is_action_just_released("Down")):
			direction_changed = true
		
	var movement_direction = Vector2()
	if Input.is_action_pressed("Left"):
		if direction_priority == "Left":
			movement_direction += LEFT*2
		else:
			movement_direction += LEFT
	if Input.is_action_pressed("Right"):
		if direction_priority == "Right":
			movement_direction += RIGHT*2.0
		else:
			movement_direction += RIGHT
	if Input.is_action_pressed("Up"):
		if direction_priority == "Up":
			movement_direction += UP*2.0
		else:
			movement_direction += UP
	if Input.is_action_pressed("Down"):
		if direction_priority == "Down":
			movement_direction += DOWN*2.0
		else:
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
	if attack_fx:
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
	dead.emit()
	
func on_hit(_body):
	# Check for i-frames
	if not blinker.blinking:
		life -= 1
		lost_life.emit(1)
		blinker.blink(0.5)
	if life <= 0:
		death()
	
func on_blinker_flip(state):
	if state:
		set_modulate(Color(1.4, 1.4, 1.4))
	else:
		set_modulate(Color(1,1,1))

func _ready():
	hitbox.hit.connect(on_hit)
	blinker.flip.connect(on_blinker_flip)

func gain_life(_life):
	life += 1
	if life >= total_life:
		life = total_life
	gained_life.emit(_life)
	
func _process(delta):
	if Input.is_action_just_pressed("GainLifeCheat"):
		gain_life(1)
	update_direction()
	update_attack_state()
	update_position(delta)
	update_animation_blend_positions()
