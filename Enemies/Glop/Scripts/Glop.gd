extends Enemy

var no_collide : Array[Weapon.Types]

func create_slime_attack() -> Attack:
	var attk_type = Weapon.Types.SLIME_TRAIL
	var attack = Attack.new().transform_into(attk_type)
	return attack
	
func drop_slime():
	var attack = create_slime_attack()
	attack.activate(self)
	
func create_sound_component():
	var sc = EnemySoundComponent.create()
	var walk_sound : ActorSound = ActorSound.new()
	walk_sound.delay = 0.33
	walk_sound.stream = load("res://Assets/Sounds/Glop/StepSound.ogg")
	walk_sound.volume = -10.0
	
	var death_sound : ActorSound = ActorSound.new()
	death_sound.stream = load("res://Assets/Sounds/Glop/DeathSound.ogg")
	death_sound.volume = -10.0
	
	var hit_sound : ActorSound = ActorSound.new()
	hit_sound.stream = load("res://Assets/Sounds/Glop/HitSound.ogg")
	hit_sound.volume = -10.0
	var sounds : Dictionary[int, ActorSound] = {
		Actions.WALK : walk_sound,
		Actions.KNOCKBACK : hit_sound,
		Actions.DEATH : death_sound
	}
	
	sc.sounds = sounds
	return sc
	
func init():
	facing = Vector2(1,0)
	sound_component = create_sound_component()
	can_transition.append("Walk")
	set_action(Actions.WALK)
	current_attack_type = Attack.Types.DROP_OBSTACLE
	no_collide.append(Weapon.Types.SLIME_TRAIL)

func process_action_walk():
	if transitioning:
		walk_speed = 0.0
		velocity = Vector2()
	else:
		var al = get_action_length()
		var pa : float = 0.25 * al
		var dink : float = 0.75 * al
		walk_speed = Utils.padink(action_timer, pa, dink)*295.0
		velocity = facing*walk_speed
	if action_finished():
		set_action(Actions.IDLE)
	update()
		

func process_action_idle():
	velocity = Vector2()
	if action_timer > 1.0:
		drop_slime()
		set_action(Actions.WALK)
	update()
		
func _process(_delta):
	process_action(_delta)

func process_action_knockback():
	set_action(Actions.WALK)
