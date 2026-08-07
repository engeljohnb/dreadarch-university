extends CharacterBody2D
class_name Enemy

# This class is a subclass sandbox: https://gameprogrammingpatterns.com/subclass-sandbox.html
# It also uses a state machine: https://gameprogrammingpatterns.com/state.html
# Subclasses can reprogram the state machine's behavior by reimplementing any of
#   the process_action_xyz functions. Or keep them and just write _process.
#	Crow is the basic vanilla enemy. Start there for examples.
#   
# Chores the subclasses need to do:
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
# attack_delay is what time within the attack animation should the weapon be created.
var attack_delay : float =  0.0
var time_between_attacks : float = 0.0
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
var blinker : Blinker
var death_cutscene : EnemyDeathCutscene #= ResourceLoader.load("res://Utils/DeathCutscene.tscn").instantiate()
var pathfinder : PathFinder
# type : odds out of 1.0
#  1.0 means always drop (unless a lower probability item was rolled), 0.0 means never
var can_drop : Dictionary[int, float]

var talons_node = load("res://Weapons/Projectiles/Talons/CrowProjectile.tscn")
@export var sprite : AnimatedSprite2D

func drop_items():
	var roll = randf()
	var lowest_probability = 1.0
	var best_items = []
	for item in can_drop:
		var odds = can_drop[item]
		if roll < odds:
			if odds < lowest_probability:
				lowest_probability = odds
				best_items.clear()
				best_items.append(item)
			elif odds == lowest_probability:
				best_items.append(item)
	if best_items.is_empty():
		return
	for i in range(0, best_items.size()):
		var drop = Collectible.create(best_items[i])
		var x_offset : float = (64 * i)
		drop.position = Vector2(position.x + x_offset, position.y)
		# So the drop doesn't get counted as an enemy by being a child of the Enemies node.
		get_parent().add_sibling(drop)

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
		# Changing this breaks things
		Actions.KNOCKBACK:
			return "Aggro"
		action:
			return "Idle"
	return "Idle"
	
# Because for some reason when using get_action_name
#  the ID for KNOCKBACK needs to return "Aggro" or things break
func get_sound_name(action : int = current_action) -> String:
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
		# Changing this breaks things
		Actions.KNOCKBACK:
			return "Knockback"
		action:
			return "Idle"
	return "Idle"
func get_animation_name(action_name : String = "") -> String:
	var animation_name = ""
	var _action_name = ""
	if action_name.is_empty():
		_action_name = get_action_name()
	else:
		_action_name = action_name
	var direction = Utils.nearest_cardinal_direction(facing, true)
	if skip_transition:
		animation_name = _action_name + " " + direction
	if transitioning:
		animation_name = "Prepare " + _action_name + " " + direction
	else:
		animation_name = _action_name + " " + direction
	return animation_name
	
func get_sound_component() -> SoundComponent:
	return get_node_or_null("SoundComponent")
	
func set_action(action : int):
	current_action = action
	if action_has_transition(action):
		set_transitioning(true)
	else:
		set_transitioning(false)
	var sc : SoundComponent = get_sound_component()
	if sc != null:
		sc.play_sound(get_sound_name(action)) 
	action_timer = 0.0

func _ready():
	prev_position = global_position
	if ($AnimatedSprite2D != null) and (sprite == null):
		sprite = $AnimatedSprite2D
	pathfinder = PathFinder.create()
	blinker = preload("res://Utils/blinker.tscn").instantiate()
	add_child(pathfinder)
	add_child(blinker)
	set_action(Actions.IDLE)
	init()
	
func moving():
	var _moving := global_position.distance_to(prev_position) > 0.0
	return _moving
	
func update_facing():
	if moving():
		facing = (global_position - prev_position).normalized()
	# NOTE TO SELF: If you find yourself adding a bunch more of these ifs
	#  find a way to do it without redundant checking of what action
	#  is set.
	if current_action == Actions.KNOCKBACK:
		facing = -facing
	
func action_has_transition(action : int = current_action) -> bool:
	var action_name = get_action_name(action)
	for _name in can_transition:
		if action_name.contains(_name):
			return true
	return false
	
func set_transitioning(value : bool):
	transitioning = value
	#breakpoint
	
func update_animation(animation_name : String = ""):
	if animation_name.is_empty():
		sprite.play(get_animation_name())
	else:
		sprite.play(animation_name)
		
func process_action_walk():
	patrol()
	
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
	action_timer += delta
	if transitioning:
		var action_length = get_action_length()
		if action_timer >= action_length:
			set_transitioning(false)
			action_timer = 0.0
	prev_position = global_position

func start_action_attack():
	current_attack_type = Attack.Types.PROJECTILE
	
func patrol():
	pathfinder.set_orders_patrol(self)
	velocity = facing * walk_speed
	if (current_action != Actions.ATTACK) and (not aggrod):
		if aggro_triggered():
			set_action(Actions.AGGRO_WARNING)
	facing = pathfinder.get_direction()
	move_and_slide()
	update_animation()
	prev_action = current_action
	
	
@warning_ignore("unused_parameter")
func create_projectile(type : int) -> Attack:
	return Attack.new().transform_into(type)
		
	
func process_action_death():
	death_cutscene = preload("res://Utils/DeathCutscene.tscn").instantiate()
	drop_items()
	get_parent().add_sibling(death_cutscene)
	death_cutscene.position = position
	death_cutscene.play(0.0, self)
	# Cludge because the death sound can't play if the enemy is freed right away,
	#   and for some reason passing the sound to the DeathCutscene doesn't work.
	var sc : SoundComponent = get_node_or_null("SoundComponent")
	if sc != null:
		sc.reparent(get_parent())
		sc.play_sound("Death")
		turn_off_physics()
	queue_free()
	# This was here at first to track down a weird bug where projectiles would 
	#  become orphans instead of being freed after calling queue_free. It's
	#  still here because hey, you never know.
	if not get_orphan_node_ids().is_empty():
		Error.error("Unhandled orphan nodes. Or, it's doing that thing again.")
		for id in get_orphan_node_ids():
			instance_from_id(id).free()
			
	
func damage(actor : Variant):
	actor.life -= 1
	if actor.life <= 0:
		if actor.life < 0:
			breakpoint
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
	
func get_action_length(action_name : String = "") -> float:
	var animation_name = ""
	if action_name.is_empty():
		animation_name = get_animation_name()
	else:
		animation_name = action_name
	var frame_count = sprite.sprite_frames.get_frame_count(animation_name)
	var rel_frame_duration = sprite.sprite_frames.get_frame_duration(animation_name, 0)
	var frame_duration = rel_frame_duration / sprite.sprite_frames.get_animation_speed(animation_name)
	#NOTE: I found animations loops were going one frame too long, causing jittering. 
	#  So I subtracted one frame's length from the final duration and it seems to be fixed.
	#  If animations are ever a frame too short, I know where to check first.
	var animation_length = (frame_count * frame_duration) - (1.0 / float(frame_count))
	return animation_length
	
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
	
func activate_attack():
	var projectile : Weapon = preload("res://Weapons/Projectiles/Talons/CrowProjectile.tscn").instantiate()
	projectile.set_parent(self)
	projectile.set_parent_hitbox(get_hitbox())
	get_parent().add_sibling(projectile)
	projectile.position = position
	projectile.activate(facing)
	
func get_attack_type_name(attack_type : int):
	match attack_type:
		Attack.Types.PROJECTILE:
			return "Projectile"
		Attack.Types.DROP_OBSTACLE:
			return "Drop Obstacle"
			
func wait():
	velocity = Vector2()
	var idle_animation = "Idle " + Utils.nearest_cardinal_direction(facing, true)
	update_animation(idle_animation)
	move_and_slide()
	
func process_action_attack():
	if action_timer == 0.0:
		start_action_attack()
	velocity = Vector2()
	update()
	match current_attack_type:
		Attack.Types.PROJECTILE:
			if action_timer >= attack_delay:
				if not attacked:
					var projectile_attack : Attack = create_projectile(0)
					projectile_attack.num_weapons = 1
					get_parent().add_sibling(projectile_attack)
					projectile_attack.activate(self, facing)
					projectile_attack.free()
					attacked = true
		Attack.Types.DROP_OBSTACLE:
			pass
	if action_timer >= get_action_length():
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

func get_player():
	return get_tree().get_nodes_in_group("Player")[0]

func chase_player(speed : float):
	velocity = facing * speed
	if attack_triggered():
		if action_timer >= time_between_attacks:
			set_action(Actions.ATTACK)
		else:
			wait()
			return
	pathfinder.set_orders_chase(null)
	facing = pathfinder.get_direction()
	move_and_slide()
	update_animation()
	prev_action = current_action
	
func process_action_aggro():
	chase_player(aggro_speed)
