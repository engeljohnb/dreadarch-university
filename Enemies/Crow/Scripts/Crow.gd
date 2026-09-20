extends Enemy
@export var default_idle : bool = false
var timer = 0.0

func set_drops():
	can_drop[ItemCollection.TALONS] = 1.0
	can_drop[ItemCollection.TREASURE] = 0.5
	can_drop[ItemCollection.HEART] = 0.33
	
func init():
	sprite = $AnimatedSprite2D
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = preload("res://Assets/BumpMap.gdshader")
	sprite.material.set_shader_parameter("strength", 0.933)
	sprite.material.set_shader_parameter("baseline", 0.166)
	can_transition.append("Walk")
	can_transition.append("Projectile")
	if default_idle:
		set_action(Actions.IDLE)
	else:
		set_action(Actions.WALK)
	set_drops()
	attack_delay = 0.33
	aggro_range = 400.0
	attack_range = 600.0
	time_between_attacks = 0.33
	
func _process(_delta):
	process_action(_delta)
