extends Enemy

var timer = 0.0
@export var path : Path

func get_hitbox():
	return $EnemyHitbox

func create_crow_sound_component() -> EnemySoundComponent:
	var sound = load("res://Enemies/EnemySoundComponent.tscn").instantiate()
	
	var aggro_warning_sound = ActorSound.new()
	aggro_warning_sound.stream = ResourceLoader.load("res://Assets/Sounds/Crow/AggroSound.ogg", "AudioStream")
	aggro_warning_sound.play_only_once = true
	
	var attack_sound = ActorSound.new()
	attack_sound.stream = ResourceLoader.load("res://Assets/Sounds/Crow/LauncProjectileSound.ogg", "AudioStream")
	attack_sound.delay = 0.33
	
	var hit_sound = ActorSound.new()
	hit_sound.stream = ResourceLoader.load("res://Assets/Sounds/Crow/HitSound.ogg", "AudioStream")
	
	var death_sound = ActorSound.new()
	death_sound.stream = ResourceLoader.load("res://Assets/Sounds/Crow/DeathSound.ogg", "AudioStream")
	
	var _sounds : Dictionary[int,ActorSound] = {
		Actions.AGGRO_WARNING : aggro_warning_sound,
		Actions.ATTACK : attack_sound,
		Actions.KNOCKBACK : hit_sound,
		Actions.DEATH : death_sound
	}
	sound.sounds = _sounds
	return sound
	
func init():
	sprite = $AnimatedSprite2D
	can_transition.append("Walk")
	can_transition.append("Projectile")
	_set_action(Actions.WALK)
	if not is_instance_valid(path):
		path = Path.new()
		path.starting_position = global_position
		path.magnitudes[0] = 150.0
		launch_projectile_delay = 0.33
	sound_component = create_crow_sound_component()
	add_child(path)
	
func _process(_delta):
	if aggrod:
		path.stop()
	else:
		path.follow(self)
	_process_action(_delta)
