extends Enemy
var no_collide : Array[Weapon.Types]
var _moving : bool = true
var _last_position : Vector2
func create_slime_attack() -> Attack:
	var attk_type = Weapon.Types.SLIME_TRAIL
	var attack = Attack.new().transform_into(attk_type)
	return attack
	
func drop_slime():
	var attack = create_slime_attack()
	attack.activate(self)
	attack.free()
	
func _update_moving():
	if _last_position == global_position:
		_moving = false
	else:
		_moving = true
		_last_position = global_position
	
func moving():
	return _moving
	
func init():
	facing = Vector2(1,0)
	can_transition.append("Walk")
	set_action(Actions.WALK)
	current_attack_type = Attack.Types.DROP_OBSTACLE
	no_collide.append(Weapon.Types.SLIME_TRAIL)
	_last_position = global_position

func aggro_triggered():
	return false
	
func process_action_walk():
	if transitioning:
		walk_speed = 0.0
		velocity = Vector2()
	else:
		var al = get_action_length()
		var pa : float = 0.25 * al
		var dink : float = 0.75 * al
		walk_speed = Utils.padink(action_timer, pa, dink) * 1300.0
		velocity = facing*walk_speed
	if action_finished():
		set_action(Actions.IDLE)
	patrol()
		

func process_action_idle():
	velocity = Vector2()
	if action_timer > 1.0:
		drop_slime()
		set_action(Actions.WALK)
		_update_moving()
	update()
		
func _process(_delta):
	process_action(_delta)

func process_action_knockback():
	set_action(Actions.WALK)
