extends CharacterBody2D
class_name Enemy

# This class is a subclass sandbox: https://gameprogrammingpatterns.com/subclass-sandbox.html
# It also uses a state machine: https://gameprogrammingpatterns.com/state.html
# Subclasses can reprogram the state machine's behavior by reimplementing any of
#   the process_action_xyz functions. Or keep them and just write _process.
#	Crow is the basic vanilla enemy. Start there for examples.
#   
# Chores the subclasses need to do:
#	Creating the sound_component
#	Adding the names to any actions with a transition animation to can_transition
#		NOTE: action names don't perfectly correspond to their IDs in the Actions enum,
#			  because "attack" ID can have multiple action names ("Projectile", "Slice", etc)

# State machine state can be set with set_action


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

var life : int = 3
var current_attack_type : int = Attack.Types.PROJECTILE
var current_action : int = Actions.IDLE
var facing : Vector2 = Vector2(0,1)
var prev_position = Vector2()
var attack_types : Array[int]
var prev_action : int = Actions.IDLE
var action_timer = 0.0
var attack_delay : float =  0.0
var projectile_type: int = 0
var skip_transition: bool = false
var attacked : bool = false
var aggro_range : float = 250.0
var attack_range : float = 150.0
var aggrod : bool = false
var walk_speed : float = 100.0
var aggro_speed : float = 100.0
var transitioning : bool = false
var can_transition : Array[String] 
var knockback_speed : float = 600.0
var knockback_direction : Vector2
var blinker : Blinker = Blinker.new()
var death_cutscene : EnemyDeathCutscene = ResourceLoader.load("res://Utils/DeathCutscene.tscn").instantiate()

var talons_node = load("res://Weapons/Projectiles/Talons/CrowProjectile.tscn")
@export var sprite : AnimatedSprite2D
@export var sound_component : EnemySoundComponent

func init():
	# Implemented by subclasses, called at the end of _ready.
	pass

func turn_off_physics():
	process_mode = Node.PROCESS_MODE_DISABLED
	
func update():
	update_facing()
	move_and_slide()
	update_animation()
	prev_action = current_action
	
func player_in_aggro_range():
	return (global_position.distance_to(Utils.player_position) < aggro_range)
	
func aggro_triggered() -> bool:
	return player_in_aggro_range()

func get_action_name(action : int = current_action) -> String:
	match action:
			Actions.IDLE:
				return "Idle"
			Actions.WALK:
				return "Walk"
			Actions.ATTACK:
				match current_attack_type:
					Attack.Types.PROJECTILE:
						return "Projectile"
					Attack.Types.DROP_OBSTACLE:
						return "Drop"
			Actions.AGGRO_WARNING:
				return "Aggro"
			Actions.AGGRO:
				return "Walk"
			Actions.KNOCKBACK:
				return "Aggro"
			action:
				return "Idle"
	return "Idle"

func get_animation_name() -> String:
	var animation_name = ""
	var action_name = get_action_name()
	var direction = Utils.nearest_cardinal_direction(facing, true)
	if skip_transition:
		animation_name = action_name + " " + direction
	if transitioning:
		animation_name = "Prepare " + action_name + " " + direction
	else:
		animation_name = action_name + " " + direction
	return animation_name
	
func set_action(action : int):
	if self.name == "Slack":
		if action == Actions.WALK or action == Actions.AGGRO:
			breakpoint
	current_action = action
	if action_has_transition(action):
		set_transitioning(true)
	else:
		set_transitioning(false)
	action_timer = 0.0

func _ready():
	prev_position = global_position
	if ($AnimatedSprite2D != null) and (sprite == null):
		sprite = $AnimatedSprite2D
	add_child(blinker)
	set_action(Actions.IDLE)
	init()
	add_child(sound_component)
	
func standing_still():
	return (not prev_position.is_equal_approx(global_position))
	
func update_facing():
	if standing_still():
		facing = (global_position - prev_position).normalized()
	# NOTE TO SELF: If you find yourself adding a bunch more of these ifs
	#  find a way to do it without redundant checking of what action
	#  is set.
	if current_action == Actions.KNOCKBACK:
		facing = -facing
	prev_position = global_position
	
func action_has_transition(action : int = current_action) -> bool:
	var action_name = get_action_name(action)
	for _name in can_transition:
		if action_name.contains(_name):
			return true
	return false
	
func set_transitioning(value : bool):
	transitioning = value
	#breakpoint
	
		
func update_animation():
	sprite.play(get_animation_name())

func process_action_walk():
	if (current_action != Actions.ATTACK) and (not aggrod):
		if aggro_triggered():
			set_action(Actions.AGGRO_WARNING)
	update()
	
func process_action_idle():
	if (current_action != Actions.ATTACK) and (not aggrod):
		if aggro_triggered():
			set_action(Actions.AGGRO_WARNING)
	update()

func process_action(delta : float):
	match current_action:
		Actions.IDLE:
			process_action_idle()
		Actions.WALK:
			process_action_walk()
		Actions.ATTACK:
			process_action_attack()
		Actions.AGGRO_WARNING:
			process_action_aggro_warning()
		Actions.AGGRO:
			process_action_aggro()
		Actions.KNOCKBACK:
			process_action_knockback()
		Actions.DEATH:
			process_action_death()
		current_action:
			process_action_idle()
	sound_component.update(current_action)
	action_timer += delta
	if transitioning:	
		var action_length = get_action_length()
		if action_timer >= action_length:
			set_transitioning(false)
			action_timer = 0.0

func start_action_attack():
	current_attack_type = Attack.Types.PROJECTILE
	

@warning_ignore("unused_parameter")
func create_projectile(type : int) -> Attack:
	return Attack.new().transform_into_talons_attack()
		
	
func process_action_death():
	# For some reason the death_cutscene node will free before this one.
	#  I don't think it's worth investigating rn.
	if death_cutscene != null:
		if not death_cutscene.is_inside_tree():
			add_sibling(death_cutscene)
			death_cutscene.position = position
			death_cutscene.play(0.0, self)
			# The sound needs to keep playing after node is disabled
			sound_component.reparent(death_cutscene)
			turn_off_physics()
			
	
func damage(actor : Variant):
	actor.life -= 1
	if actor.life <= 0:
		actor.set_action(Actions.DEATH)
		
var knockback_applied : bool = false
func process_action_knockback():
	facing = -facing
	if not knockback_applied:
		velocity += knockback_direction * knockback_speed
		knockback_applied = true
	update()
	if action_timer >= get_action_length():
		if aggrod:
			set_action(Actions.AGGRO)
		else:
			set_action(Actions.WALK)
		knockback_applied = false


func hit(body : Variant):
	if not blinker.blinking:
		knockback_direction = -(body.get_parent().global_position - global_position).normalized()
		knockback_speed = 325.0
		set_action(Actions.KNOCKBACK)
		damage(self)
		blinker.blink(0.5, self)
		attacked = false
	

	
func get_action_length() -> float:
	var animation_name = get_animation_name()
	var frame_count = sprite.sprite_frames.get_frame_count(animation_name)
	var rel_frame_duration = sprite.sprite_frames.get_frame_duration(animation_name, 0)
	var frame_duration = rel_frame_duration / sprite.sprite_frames.get_animation_speed(animation_name)
	#NOTE: I found animations loops were going one frame too long, causing jittering. 
	#  So I subtracted one frame's length from the final duration and it seems to be fixed.
	#  If animations are ever a frame too short, I know where to check first.
	return (frame_count * frame_duration) - (1.0 / float(frame_count))
	
func get_hitbox() -> Hitbox:
	for child in get_children():
		if child is Hitbox:
			return child
	return Hitbox.new()

func end_action_attack(_animation_name = ""):
	if aggrod:
		set_action(Actions.AGGRO)
	else:
		set_action(Actions.WALK)
	attacked = false

func process_action_attack():
	if action_timer == 0.0:
		start_action_attack()
	velocity = Vector2()
	update()
	match current_attack_type:
		Attack.Types.PROJECTILE:
			if action_timer >= attack_delay:
				if not attacked:
					create_projectile(0).activate(self)
					attacked = true
		Attack.Types.DROP_OBSTACLE:
			pass
	if action_finished():
		if not transitioning:
			end_action_attack()
	
func action_finished():
	return (action_timer >= get_action_length())
	
func process_action_aggro_warning():
	velocity = Vector2()
	if action_timer >= get_action_length():
		aggrod = true
		set_action(Actions.AGGRO)

func player_in_attack_range():
	return (global_position.distance_to(Utils.player_position) < attack_range)
	
func attack_triggered():
	return player_in_attack_range()
	
func update_velocity(max_speed, delta):
	if velocity.x > max_speed:
		velocity.x -= (10.0 * delta)
	if velocity.y > max_speed:
		velocity.y -= (10.0 * delta)
	
func chase_player(speed : float):
	prev_position = global_position
	facing = (Utils.player_position - global_position).normalized()
	velocity = facing * speed
	if attack_triggered():
		set_action(Actions.ATTACK)
	update_facing()
	move_and_slide()
	update_animation()
	prev_action = current_action
	
func physics_process(delta):
	if velocity.x > max(walk_speed, aggro_speed):
		velocity.x -= (0.5*delta)
	if velocity.y > max(walk_speed, aggro_speed):
		velocity.y -= (0.5*delta)
	
func process_action_aggro():
	chase_player(aggro_speed)
