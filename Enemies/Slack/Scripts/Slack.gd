extends Enemy
@export var mirrored : bool = false
var player_nearby = false

func player_in_attack_range() -> bool:
	return player_nearby
	
func make_projectile_attack() -> Attack:
	return Attack.new().transform_into_orbiter_attack()
	
func activate_attack(projectile_attack : Attack):
	call_deferred("add_sibling", projectile_attack.node)
	projectile_attack.node.position = position
	if mirrored:
		projectile_attack.node.call_deferred("activate", Utils.nearest_cardinal_direction(-facing))
	else:
		projectile_attack.node.call_deferred("activate", Utils.nearest_cardinal_direction(facing))
	projectile_attack.node.set_parent_hitbox($EnemyHitbox)
	
func create_sound_component() -> EnemySoundComponent:
	var attack_sound : ActorSound = ActorSound.new()
	attack_sound.delay = 0.5
	attack_sound.stream = load("res://Assets/Sounds/Heart/CollectSound.ogg")
	attack_sound.volume = -10.0
	var sounds : Dictionary[int,ActorSound] = {
		Actions.ATTACK : attack_sound
	}
	
	var sc = EnemySoundComponent.create()
	sc.sounds = sounds
	return sc
	
func update_facing():
	pass
	
func init():
	sprite = $AnimatedSprite2D
	facing = Vector2(-1,0)
	if mirrored:
		sprite.scale.x = -sprite.scale.x
	sound_component = create_sound_component()
	$SearchArea.player_nearby.connect(func (_body): player_nearby = true)
	$SearchArea.player_went_away.connect(func (): player_nearby = false)
	attack_delay = 0.5
	life = 1
	
func hit(_actor : Variant):
	set_action(Actions.DEATH)
	
func process_action_idle():
	if action_timer > 1.0:
		if player_in_attack_range():
			set_action(Actions.ATTACK)
	update()
	
func process_action_attack():
	if action_timer >= attack_delay:
		if not attacked:
			make_projectile_attack().activate(self, -facing)
			attacked = true
	update()
	if action_timer >= get_action_length():
		set_action(Actions.IDLE)
		attacked = false
	
func _process(_delta):
	process_action(_delta)
