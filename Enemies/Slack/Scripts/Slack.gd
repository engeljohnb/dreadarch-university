extends Enemy
@export var mirrored : bool = false
var player_nearby = false

func player_in_attack_range() -> bool:
	return player_nearby
	
func make_projectile_attack() -> Attack:
	return Attack.new().transform_into_orbiter_attack()
	
func _activate_attack(projectile_attack : Attack):
	get_parent().add_sibling(projectile_attack.node)
	projectile_attack.node.position = position
	if mirrored:
		projectile_attack.node.call_deferred("activate", Utils.nearest_cardinal_direction(-facing))
	else:
		projectile_attack.node.call_deferred("activate", Utils.nearest_cardinal_direction(facing))
	projectile_attack.node.set_parent_hitbox($EnemyHitbox)
	
func update_facing():
	pass
	
func init():
	sprite = $AnimatedSprite2D
	facing = Vector2(-1,0)
	if mirrored:
		sprite.scale.x = -sprite.scale.x
	$SearchArea.player_nearby.connect(func (_body): player_nearby = true)
	$SearchArea.player_went_away.connect(func (): player_nearby = false)
	attack_delay = 0.5
	life = 1
	can_drop[ItemCollection.ORBITER] = 1.0

func hit(_actor : Variant):
	life = 0
	set_action(Actions.DEATH)
	
func process_action_idle():
	if action_timer > 1.0:
		if player_in_attack_range():
			set_action(Actions.ATTACK)
	update()
	
func process_action_attack():
	if action_timer >= attack_delay:
		if not attacked:
			var attack = make_projectile_attack()
			attack.activate(self, -facing)
			attacked = true
			attack.free()
	update()
	if action_timer >= get_action_length():
		set_action(Actions.IDLE)
		attacked = false
	
func _process(_delta):
	process_action(_delta)
