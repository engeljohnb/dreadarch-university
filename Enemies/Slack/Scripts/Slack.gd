extends Enemy
@export var mirrored : bool = false
var player_nearby = false

func _player_in_attack_range() -> bool:
	return player_nearby
	
func make_projectile() -> ProjectileAttack:
	var projectile : ProjectileAttack = ProjectileAttack.new()
	projectile.num_projectiles = 1
	projectile.node = load("res://Enemies/Slack/Projectile/SlackProjectile.tscn").instantiate()
	return projectile
	
func _launch_projectile(projectile : ProjectileAttack):
	call_deferred("add_sibling", projectile.node)
	projectile.node.position = position
	if mirrored:
		projectile.node.call_deferred("launch", Utils.nearest_cardinal_direction(-facing))
	else:
		projectile.node.call_deferred("launch", Utils.nearest_cardinal_direction(facing))
	projectile.node.set_parent_hitbox($EnemyHitbox)
	
func create_sound_component() -> EnemySoundComponent:
	var attack_sound : ActorSound = ActorSound.new()
	attack_sound.delay = 0.5
	attack_sound.stream = load("res://Assets/Sounds/Heart/CollectSound.ogg")
	attack_sound.volume = -10.0
	var sounds : Dictionary[int,ActorSound] = {
		Actions.ATTACK : attack_sound
	}
	
	var sc = load("res://Enemies/EnemySoundComponent.tscn").instantiate()
	sc.sounds = sounds
	return sc
	
func _update_facing():
	pass
	
func init():
	sprite = $AnimatedSprite2D
	facing = Vector2(-1,0)
	if mirrored:
		sprite.scale.x = -sprite.scale.x
	sound_component = create_sound_component()
	$SearchArea.player_nearby.connect(func (_body): player_nearby = true)
	$SearchArea.player_went_away.connect(func (): player_nearby = false)
	launch_projectile_delay = 0.5
	life = 1
	
func hit(_actor : Variant):
	_set_action(Actions.DEATH)
	
func _process_action_idle():
	if action_timer > 1.0:
		if _player_in_attack_range():
			_set_action(Actions.ATTACK)
	_update()
	
func _process_action_attack():
	if action_timer >= launch_projectile_delay:
		if not projectile_launched:
			_launch_projectile(make_projectile())
			projectile_launched = true
	_update()
	if action_timer >= _get_action_length():
		_set_action(Actions.IDLE)
		projectile_launched = false
	
func _process(_delta):
	_process_action(_delta)
