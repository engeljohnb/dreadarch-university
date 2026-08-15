extends Node2D
signal travel_ended
@onready var fx_sprite : Sprite2D = $FX

var transitioning : bool = false
var _timer := 0.0
var _original_spotlight_size = 1.935
var _current_spotlight_size = _original_spotlight_size
var _current_spotlight_2_scale = _original_spotlight_size

func _process(delta):
	var n : NoiseTexture2D = fx_sprite.material.get_shader_parameter("noise")
	var noise : FastNoiseLite = n.noise
	
	noise.offset.y += delta
	noise.offset.x += delta
	if transition_triggered():
		transitioning = true
	if transitioning:
		transition_to_stationary(delta)

func transition_triggered() -> bool:
	return false

func begin_transition():
	transitioning = true

func transition_to_stationary(delta : float):
	_current_spotlight_size -= (delta)
	_current_spotlight_2_scale += (delta*100.0)
	fx_sprite.material.set_shader_parameter("spotlight_size", _current_spotlight_size)
	fx_sprite.material.set_shader_parameter("spotlight_2_scale", _current_spotlight_2_scale)
	fx_sprite.material.set_shader_parameter("distance_from_center_xp", 3)
	if _current_spotlight_size <= 0.95:
		visible = false
		transitioning = false
		travel_ended.emit()
	
func _set_params(s1 : float = _current_spotlight_size, s2 : float = _current_spotlight_2_scale, xp : int = 3):
	fx_sprite.material.set_shader_parameter("spotlight_size", s1)
	fx_sprite.material.set_shader_parameter("spotlight_2_scale", s2)
	fx_sprite.material.set_shader_parameter("distance_from_center_xp", xp)
	
var _inc := true
func pulsate(delta : float):
	var duration = 0.66
	var start = _original_spotlight_size - 0.1
	var end = _original_spotlight_size - 0.4
	var padink = Utils.padink(_timer, duration, 0.2, 1.2, 1.3, start, end)
	_set_params(padink, padink, 2)
	if _inc:
		_timer += delta
	else:
		_timer -= delta
	if (_timer >= duration) or (_timer <= 0.0):
		_inc = not _inc
