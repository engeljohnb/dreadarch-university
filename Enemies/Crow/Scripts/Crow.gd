extends Enemy

var timer = 0.0

func set_drops():
	can_drop[ItemCollection.TALONS] = 1.0
	can_drop[ItemCollection.TREASURE] = 0.5
	can_drop[ItemCollection.HEART] = 0.33
	
func init():
	sprite = $AnimatedSprite2D
	can_transition.append("Walk")
	can_transition.append("Projectile")
	set_action(Actions.WALK)
	set_drops()
	attack_delay = 0.33
	aggro_range = 400.0
	attack_range = 600.0
	time_between_attacks = 0.33
	
func _process(_delta):
	process_action(_delta)
