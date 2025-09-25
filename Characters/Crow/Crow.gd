extends CharacterBody2D

@onready var search_area = $SearchArea
@onready var search_ray = $SearchRay
@onready var hitbox = $Hitbox
@onready var blinker = $Blinker
@onready var animation_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
const SPEED = 100.0

var can_drop = [Collectible.TALONS, Collectible.TREASURE]
var entered_scene = true
var player = null
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
var death_cutscene_speed = 2.66
var death_cutscene_duration = 1.0
var aggro_cutscene_duration = 0.5
var attack_range = 300.0
var dead = false
var dropped = false
var to_player = Vector2()
var current_action = ""
var max_idle_time = 0.33
var direction_change_counter = 0

func drop():
	var drop_gen = RandomNumberGenerator.new()
	var odds = drop_gen.randf()
	var item = null
	if odds > 0.1:
		item = load("res://Items/Treasure/Treasure.tscn").instantiate()
	if odds > 0.4:
		item = load("res://Items/Talons/Talons.tscn").instantiate()
	if item == null:
		return
	add_sibling(item)
	item.global_position = global_position
	item.reparent(get_parent())
	item.visible = true
	item.z_index = 0

func play_aggro_cutscene(delta = 0.0):
	moving = false
	global_position = prev_position
	animation_player.set_animation("Aggro")
	if delta == 0.0:
		in_cutscene = true
		current_cutscene = play_aggro_cutscene
		if player:
			facing = (player.global_position - global_position).normalized()
	else:
		cutscene_timer += delta
		if cutscene_timer >= aggro_cutscene_duration:
			cutscene_timer = 0.0
			in_cutscene = false

func play_death_cutscene(delta = 0.0):
	in_cutscene = true
	current_cutscene = play_death_cutscene
	var deathlight = $DeathLight
	if (delta == 0.0):
		$DeathSound.play()
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
		var cutscene_percent = cutscene_timer/death_cutscene_speed
		deathlight.energy = 1.0/cutscene_percent
		if cutscene_timer >= death_cutscene_duration:
			queue_free()
	
func death():
	dead = true
	play_death_cutscene(0.0)

func on_blinker_flip(state):
	if state:
		set_modulate(Color(1.6, 1.6, 1.6))
	else:
		set_modulate(Color(1,1,1))

func on_hit(_body):
	if (not blinker.blinking):
		if life > 1:
			$HitSound.play()
		if _body.get_parent().is_in_group("Player"):
			knockback_direction = (_body.get_parent().global_position - global_position).normalized()
			knockback_speed = 650
		blinker.blink(0.5)
		life -= 1
		if life <= 0:
			death()

func _ready():
	search_area.player_nearby.connect(_on_player_nearby)
	hitbox.hit.connect(on_hit)
	blinker.flip.connect(on_blinker_flip)
	
func launch_projectile():
	var projectile = _projectile.instantiate()
	hitbox.my_weapon = projectile
	hitbox.my_weapons.append(projectile)
	# Add as sibling instead of child so Crow's movement doesn't
	# affect the projectile
	projectile.global_position = position
	add_sibling(projectile)
	projectile.launch(facing)
	
func _on_player_nearby(_player):
	aggrod = true
	if not player:	
		player = _player
		play_aggro_cutscene()
		$AggroSound.play()
	else:
		player = _player
	
func update_movement(_delta):
	if blinker.blinking:
		velocity = -(knockback_direction*knockback_speed*_delta)
	knockback_speed -= 10.0
	if knockback_speed < 0.0:
		knockback_speed = 0.0
	else:
		position += velocity
		move_and_slide()
		return
	if aggrod:
		if attacking:
			global_position = prev_position
			velocity = Vector2()
		else:
			to_player = (player.global_position - global_position).normalized()
			var max_distance_from_player = 150.0
			var aggro_speed = 125.0
			var new_velocity: Vector2 = global_position.direction_to(player.global_position) * aggro_speed
			if player:
				if global_position.distance_to(player.global_position) < max_distance_from_player:
					new_velocity = Vector2()
					moving = false
				else:
					moving = true
			velocity = new_velocity
	move_and_slide()

func update_direction():
	direction_changed = false
	if entered_scene:
		direction_changed = true
	var prev_facing = facing
	facing = (global_position - prev_position).normalized()
	direction_change_counter += abs(facing.angle_to(prev_facing))
	if aggrod and not attacking:
		facing = (player.global_position - global_position).normalized()
	else:
		if ((abs(facing.x) < 0.1) and (abs(facing.y) < 0.1)) or attacking:
			facing = prev_facing
			moving = false
		else:
			moving = true
	if (direction_change_counter >= (PI/2)+1.0):
		direction_change_counter = 0
		if not attacking:
			direction_changed = true
	search_ray.target_position = facing * attack_range
	
func update_attack():
	if search_ray.is_colliding():
		if (search_ray.get_collider() == player):
			attacking = true

func _physics_process(_delta):
	if blinker.blinking:
		velocity += -to_player*(knockback_direction*knockback_speed*_delta)
	knockback_speed -= 25.0
	if knockback_speed < 0.0:
		knockback_speed = 0.0
		
func _process(_delta):
	if dead and (not dropped):
		drop()
		dropped = true
	if not in_cutscene:
		update_movement(_delta)
		update_direction()
		if aggrod:
			if (not player.in_dialogue) and (not player.in_cutscene):
				update_attack()
			else:
				attacking = false
		animation_player.update_animation(direction_changed, moving, attacking)
	else:
		if current_cutscene:
			current_cutscene.call(_delta)
	if entered_scene:
		entered_scene = false
	prev_position = global_position
