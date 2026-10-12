extends Enemy
@export var default_idle : bool = false
var timer = 0.0
var dead := false

func set_drops():
	can_drop[ItemCollection.TALONS] = 1.0
	can_drop[ItemCollection.TREASURE] = 0.5
	can_drop[ItemCollection.HEART] = 0.33
	
func change_shader():
	var mat : ShaderMaterial = $AnimatedSprite2D.material
	var strength = mat.get_shader_parameter("strength")
	var baseline = mat.get_shader_parameter("baseline")
	mat.shader = preload("res://Enemies/vanquished.gdshader")
	mat.set_shader_parameter("strength", strength)
	mat.set_shader_parameter("baseline", baseline)
	mat.set_shader_parameter("dissolve_noise", preload("res://Enemies/VanquishedDissolveNoise.tres"))

func process_action_death():
	if not dead:
		dead = true
		change_shader()
		var dir = global_position.direction_to(Utils.player_position)
		var dir_string = Utils.nearest_cardinal_direction(dir, true)
		if dir_string == "Left":
			$AnimatedSprite2D.play("Vanquished Left")
		else:
			$AnimatedSprite2D.play("Vanquished Right")
		$AnimatedSprite2D.animation_finished.connect(func (): queue_free())
		get_sound_component().play_sound("Death")
	else:
		var mat : ShaderMaterial = $AnimatedSprite2D.material
		mat.set_shader_parameter("dissolve_value", (2.0 - (timer*2.0)))
		timer += get_process_delta_time()
	
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
