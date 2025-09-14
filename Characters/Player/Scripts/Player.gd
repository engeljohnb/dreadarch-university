extends CharacterBody2D

signal died()
signal lost_life(damage)
signal gained_life(life)
@onready var anim_tree = $AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Hitbox
@onready var blinker = $Blinker
@onready var light = $PointLight2D
@onready var attack_sound = $AttackSound
@onready var sprite = $AnimatedSprite2D

const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const SPEED = 300.0

var dead = false
var in_cutscene = false
var current_cutscene = null
var cutscene_timer = 0.0
var cutscene_duration = 0.0
var life = 3
var total_life = 3
var _attack_fx = load("res://Characters/Player/PlayerAttackFX.tscn")
var attack_fx = null
var facing : Vector2
var prev_facing = Vector2(0,1)
var direction_changed = false
var moving = false
var knife_equipped = true
var attacking = false
var won = false
var door_cutscene = {"position": Vector2(), "player_start_pos": Vector2(), "reverse": false, "min_scale": 0.8}
# For counting frames to know when to play the step sound
var direction_priority

func direction_just_released():
	return (Input.is_action_just_released("Left")
		or Input.is_action_just_released("Right")
		or Input.is_action_just_released("Up")
		or Input.is_action_just_released("Down"))
		
func direction_just_pressed():
	return (Input.is_action_just_pressed("Left")
		or Input.is_action_just_pressed("Right")
		or Input.is_action_just_pressed("Up")
		or Input.is_action_just_pressed("Down"))
		
func direction_held():
	return (Input.is_action_pressed("Left")
	or Input.is_action_pressed("Right")
	or Input.is_action_pressed("Up")
	or Input.is_action_pressed("Down"))
	
func play_door_cutscene(delta, door_position = Vector2(), reverse = false):
	if delta == 0.0:
		door_cutscene["reverse"] = reverse
		if reverse:
			if knife_equipped:
				sprite.play("Walk Knife Down")
			else:
				sprite.play("Walk Down")
			modulate.a = 0
		else:
			sprite.play("Walk Up")
		door_cutscene["position"] = door_position
		door_cutscene["player_start_pos"] = global_position
		in_cutscene = true
		current_cutscene = play_door_cutscene
		cutscene_duration = 1.0
		cutscene_timer = 0.0
	else:
		cutscene_timer += delta
		if door_cutscene["reverse"]:
			modulate.a = cutscene_timer
			var target_position = Vector2(door_cutscene["position"].x, door_cutscene["position"].y + hitbox.shape.get_rect().size.y+50.0)
			global_position = lerp(SceneTransition.player_start_position, target_position, cutscene_timer)
			scale = lerp(Vector2(1.0,1.0)*door_cutscene["min_scale"], Vector2(1.0,1.0), cutscene_timer)
		else:
			scale = lerp(Vector2(1.0,1.0), Vector2(1.0,1.0)*door_cutscene["min_scale"],  cutscene_timer)
			global_position = lerp(door_cutscene["player_start_pos"], door_cutscene["position"], cutscene_timer)
			modulate.a = 1.0 - cutscene_timer
		if cutscene_timer >= cutscene_duration:
			if door_cutscene["reverse"]:
				scale = Vector2(1.0,1.0)
				modulate.a = 1.0
				if knife_equipped:
					sprite.play("Idle Knife Down")
				else:
					sprite.play("Idle Down")
				facing = DOWN
				prev_facing = DOWN
			in_cutscene = false
			cutscene_timer = 0.0
			cutscene_duration = 0.0
	
func play_victory_cutscene(delta):
	won = true
	in_cutscene = true
	current_cutscene = play_victory_cutscene
	cutscene_duration = 3.0
	$AnimatedSprite2D.play("Idle Down")
	$StepSound.stop()
	cutscene_timer += delta
	if cutscene_timer >= cutscene_duration:
		in_cutscene = false
		current_cutscene = null
		cutscene_timer = 0.0

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
		if direction_just_released():
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
		facing = prev_facing
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
		attack_sound.play()
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
	if direction_held():
		if not $StepSound.playing:
			$StepSound.play()
	else:
		$StepSound.stop()
	if moving:
		position += SPEED * facing * delta
	move_and_slide()
	#print(Input.is_action_pressed("Left"), Input.is_action_pressed("Right"), direction_held())
	
func death():
	dead = true
	died.emit()
	
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
		set_modulate(Color(1.6, 1.6, 1.6))
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
	if (not in_cutscene):
		if Input.is_action_just_pressed("GainLifeCheat"):
			gain_life(1)
		update_direction()
		update_attack_state()
		update_position(delta)
		update_animation_blend_positions()
		prev_facing = facing
	else:
		if current_cutscene:
			current_cutscene.call(delta)
