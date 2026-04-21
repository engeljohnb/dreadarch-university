extends CharacterBody2D
class_name Enemy

#i dont understand why the transition from prepare_attack to attack is broken

class ProjectileAttack:
	var num_projectiles : int = 1
	var type : int = 0
	var node : Variant

enum Actions
{
	IDLE = 0,
	WALK,
	ATTACK,
	AGGRO_WARNING,
	AGGRO,
	KNOCKBACK,
	DEATH
}

enum AttackTypes
{
	PROJECTILE = 0,
}

enum ProjectileTypes
{
	TALONS = 0
}
var life : int = 3
var current_attack_type : int = AttackTypes.PROJECTILE
var current_action : int = Actions.IDLE
var facing : Vector2 = Vector2(0,1)
var _prev_position = Vector2()
var attack_types : Array[int]
var prev_action : int = Actions.IDLE
var action_timer = 0.0
var launch_projectile_delay : float =  0.0
var projectile_type: int = 0
var skip_transition: bool = false
var projectile_launched : bool = false
var aggro_range : float = 250.0
var attack_range : float = 150.0
var aggrod : bool = false
var walk_speed : float = 100.0
var aggro_speed : float = 100.0
var _transitioning : bool = false
var can_transition : Array[String] 
var knockback_speed : float = 600.0
var knockback_direction : Vector2
var blinker : Blinker = Blinker.new()
var death_cutscene : EnemyDeathCutscene = ResourceLoader.load("res://Utils/DeathCutscene.tscn").instantiate()

var talons_node = load("res://Enemies/Crow/Projectile/CrowProjectile.tscn")
@export var sprite : AnimatedSprite2D
@export var sound_component : EnemySoundComponent
# Implemented by subclasses
func init():
	pass

func turn_off_physics():
	process_mode = Node.PROCESS_MODE_DISABLED
	
func _update():
	if (current_action != Actions.ATTACK) and (not aggrod):
		if _aggro_triggered():
			_set_action(Actions.AGGRO_WARNING)
	_update_facing()
	move_and_slide()
	_update_animation()
	prev_action = current_action
	
func _player_in_aggro_range():
	return (global_position.distance_to(Utils.player_position) < aggro_range)
	
func _aggro_triggered() -> bool:
	return _player_in_aggro_range()

func _get_action_name(action : int = current_action) -> String:
	if action == Actions.ATTACK:
		match current_attack_type:
			AttackTypes.PROJECTILE:
				return "Projectile"
	match action:
			Actions.IDLE:
				return "Idle"
			Actions.WALK:
				return "Walk"
			Actions.ATTACK:
				return "Attack"
			Actions.AGGRO_WARNING:
				return "Aggro"
			Actions.AGGRO:
				return "Walk"
			Actions.KNOCKBACK:
				return "Aggro"
			action:
				return "Idle"
	return "Idle"
				
func _set_action(action : int):
	current_action = action
	if _can_transition(action):
		set_transitioning(true)
	else:
		set_transitioning(false)
	action_timer = 0.0

func _ready():
	_prev_position = global_position
	add_child(blinker)
	init()
	add_child(sound_component)
	
func _update_facing():
	if not _prev_position.is_equal_approx(global_position):
		facing = (global_position - _prev_position).normalized()
	# NOTE TO SELF: If you find yourself adding a bunch more of these ifs
	#  find a way to do it without redundant checking of what action
	#  is set.
	if current_action == Actions.KNOCKBACK:
		facing = -facing
	_prev_position = global_position
	
func _can_transition(action : int = current_action) -> bool:
	var action_name = _get_action_name(action)
	for _name in can_transition:
		if action_name.contains(_name):
			return true
	return false
	
func set_transitioning(value : bool):
	_transitioning = value
	#breakpoint
	
func _get_animation_name() -> String:
	var animation_name = ""
	var action_name = _get_action_name()
	var direction = Utils.nearest_cardinal_direction(facing, true)
	if skip_transition:
		animation_name = action_name + " " + direction
	if _transitioning:
		animation_name = "Prepare " + action_name + " " + direction
	else:
		animation_name = action_name + " " + direction
	return animation_name
		
func _update_animation():
	sprite.play(_get_animation_name())

func _process_action_walk():
	_update()
	
func _process_action_idle():
	_update()

func _process_action(delta : float):
	match current_action:
		Actions.IDLE:
			_process_action_walk()
		Actions.WALK:
			_process_action_idle()
		Actions.ATTACK:
			_process_action_attack()
		Actions.AGGRO_WARNING:
			_process_action_aggro_warning()
		Actions.AGGRO:
			_process_action_aggro()
		Actions.KNOCKBACK:
			process_action_knockback()
		Actions.DEATH:
			process_action_death()
		current_action:
			_process_action_idle()
	sound_component.update(current_action)
	action_timer += delta
	if _transitioning:	
		var action_length = _get_action_length()
		if action_timer >= action_length:
			set_transitioning(false)
			action_timer = 0.0

func _start_action_attack():
	current_attack_type = AttackTypes.PROJECTILE
	
func _create_talons_attack(num_projectiles = 1) -> ProjectileAttack:
	var talons : ProjectileAttack = ProjectileAttack.new()
	talons.num_projectiles = num_projectiles
	talons.node = talons_node.instantiate()
	return talons

@warning_ignore("unused_parameter")
func _create_projectile(type : int) -> ProjectileAttack:
	return _create_talons_attack()
		
func _launch_projectile():
	var projectile = _create_projectile(0)
	call_deferred("add_sibling", projectile.node)
	projectile.node.position = position
	projectile.node.call_deferred("launch", Utils.nearest_cardinal_direction(facing))
	projectile.node.set_parent_hitbox($EnemyHitbox)
	
func process_action_death():
	# For some reason the death_cutscene node will free before this one.
	#  I don't think it's worth investigating rn.
	if death_cutscene != null:
		if not death_cutscene.is_inside_tree():
			add_sibling(death_cutscene)
			death_cutscene.position = position
			death_cutscene.play(0.0, self)
			# The sound needs to keep laying after node is disabled
			sound_component.reparent(death_cutscene)
			turn_off_physics()
			
	
func damage(actor : Variant):
	actor.life -= 1
	if actor.life <= 0:
		actor._set_action(Actions.DEATH)
		
var knockback_applied : bool = false
func process_action_knockback():
	if not knockback_applied:
		velocity += knockback_direction * knockback_speed
		knockback_applied = true
	_update()
	if action_timer >= _get_action_length():
		if aggrod:
			_set_action(Actions.AGGRO)
		else:
			_set_action(Actions.WALK)
		knockback_applied = false


func hit(body):
	if not blinker.blinking:
		knockback_direction = -(body.get_parent().global_position - global_position).normalized()
		knockback_speed = 325.0
		_set_action(Actions.KNOCKBACK)
		damage(self)
		facing = -facing
		blinker.blink(0.5, self)
	
func _end_action_attack(_animation_name = ""):
	if aggrod:
		_set_action(Actions.AGGRO)
	else:
		_set_action(Actions.WALK)
	projectile_launched = false
	
func _get_action_length() -> float:
	var animation_name = _get_animation_name()
	var frame_count = sprite.sprite_frames.get_frame_count(animation_name)
	var rel_frame_duration = sprite.sprite_frames.get_frame_duration(animation_name, 0)
	var frame_duration = rel_frame_duration / sprite.sprite_frames.get_animation_speed(animation_name)
	#NOTE: I found animations loops were going one frame too long, causing jittering. 
	#  So I subtracted one frame's length from the final duration and it seems to be fixed.
	#  If animations are ever a frame too short, I know where to check first.
	return (frame_count * frame_duration) - (1.0 / float(frame_count))
	
func _process_action_attack():
	if action_timer == 0.0:
		_start_action_attack()
	velocity = Vector2()
	_update()
	var action_length : float = _get_action_length()
	if action_timer >= launch_projectile_delay:
		if not projectile_launched:
			_launch_projectile()
			projectile_launched = true
	if action_timer >= action_length:
		if not _transitioning:
			_end_action_attack()
	
func _process_action_aggro_warning():
	velocity = Vector2()
	if action_timer >= _get_action_length():
		aggrod = true
		_set_action(Actions.AGGRO)

func _player_in_attack_range():
	return (global_position.distance_to(Utils.player_position) < attack_range)
	
func _attack_triggered():
	return _player_in_attack_range()
	
func update_velocity(max_speed, delta):
	if velocity.x > max_speed:
		velocity.x -= (10.0 * delta)
	if velocity.y > max_speed:
		velocity.y -= (10.0 * delta)
	
func _chase_player(speed : float):
	_prev_position = global_position
	facing = (Utils.player_position - global_position).normalized()
	velocity = facing * speed
	if _attack_triggered():
		_set_action(Actions.ATTACK)
	_update_facing()
	move_and_slide()
	_update_animation()
	prev_action = current_action
	
func _physics_process(delta):
	if velocity.x > max(walk_speed, aggro_speed):
		velocity.x -= (0.5*delta)
	if velocity.y > max(walk_speed, aggro_speed):
		velocity.y -= (0.5*delta)
	
func _process_action_aggro():
	_chase_player(aggro_speed)
