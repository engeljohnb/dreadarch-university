extends CharacterBody2D

var facing = Utils.RIGHT
var idle_duration = 0.5
var idle_timer = 0.0
var moving = false
var movement_range = 64.0
var start_position : Vector2
var target_position : Vector2
var movement_progress = 0.0
var life = 2
var made_slime = false
var _slime = load("res://Characters/Glop/SlimeTrail/SlimeTrail.tscn")
var played_walk = false
var prev_facing = Utils.RIGHT
var direction_changed = false

@onready var current_ray = $DownRay
@onready var down_ray = $DownRay
@onready var up_ray = $UpRay
@onready var left_ray = $LeftRay
@onready var right_ray = $RightRay
func get_animation_name(action : String):
	return action + " " + Utils.nearest_cardinal_direction(facing, true)
	
func on_hit(_body):
	life -= 1
	if life <= 0:
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$DeathSound.play()
		$DeathCutscene.play()
	else:
		$HitSound.play()
		$Blinker.blink(0.33)

func on_flip(state):
	if state:
		modulate = Color(1.4,1.4,1.4)
	else:
		modulate = Color(1,1,1)
		
func _ready():
	$AnimatedSprite2D.play(get_animation_name("Idle"))
	$Hitbox.my_weapons.append(self)
	$Hitbox.hit.connect(on_hit)
	$Blinker.flip.connect(on_flip)
	
func facing_down():
	return (Utils.nearest_cardinal_direction(facing, true) == "Down")
	
func drop_slime():
	var slime = _slime.instantiate()
	$Hitbox.my_weapons.append(slime)
	slime.position = (start_position + target_position)/2.0
	if facing_down():
		slime.position -= Vector2(0,5)
	else:
		slime.position += Vector2(0,25)
	slime.rotation = Utils.RIGHT.angle_to(facing)
	add_sibling(slime)
	slime.z_index = -1
	if facing != prev_facing:
		slime.position += (facing*18.0)

func next_ray():
	match current_ray:
		down_ray:
			return $LeftRay
		right_ray:
			return $DownRay
		up_ray:
			return $RightRay
		left_ray:
			return $UpRay

func get_direction_from_ray(ray):
	match ray:
		down_ray:
			return Utils.DOWN
		right_ray:
			return Utils.RIGHT
		up_ray:
			return Utils.UP
		left_ray:
			return Utils.LEFT
	
func find_best_direction():
	var num_directions_checked = 0
	while num_directions_checked < 4:
		if current_ray.is_colliding():
			current_ray = next_ray()
		else:
			return get_direction_from_ray(current_ray)
		num_directions_checked += 1
	return Vector2()

func turn():
	facing = facing.rotated(PI/2.0)
	
func update_direction():
	facing = find_best_direction()
	
func update_position(delta):
	if facing.is_zero_approx():
		$AnimatedSprite2D.play("Idle Down")
		return
	else:
		if not played_walk:
			target_position = position + (facing*movement_range)
			start_position = position
			played_walk = true
			$AnimatedSprite2D.play(get_animation_name("Walk"))
	if $AnimatedSprite2D.frame >= 7:
		position = lerp(position, target_position, movement_progress)
		movement_progress += delta
		if not made_slime:
			made_slime = true
			drop_slime()
	if ($AnimatedSprite2D.frame >= 14) and ($AnimatedSprite2D.frame_progress > 0.5):
		prev_facing = facing
		$AnimatedSprite2D.play(get_animation_name("Idle"))
		movement_progress = 0.0
		target_position = Vector2()
		start_position = Vector2()
		moving = false
		made_slime = false
		played_walk = false
	
func _process(_delta):
	update_direction()
	if moving:
		update_position(_delta)
	else:
		idle_timer += _delta
		if idle_timer >= idle_duration:
			$StepSound.play()
			$AnimatedSprite2D.play(get_animation_name("Walk"))
			idle_timer = 0.0
			moving = true
			target_position = position + (facing*movement_range)
			start_position = position
