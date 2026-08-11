extends Node2D
signal travel_ended
@onready var fx_sprite : Sprite2D = $FX

var transitioning : bool = false
var _original_spotlight_size = 1.935
var _original_spotlight_2_scale = _original_spotlight_size
var _current_spotlight_size = _original_spotlight_size
var _current_spotlight_2_scale = _original_spotlight_size

func _process(delta):
	var n : NoiseTexture2D = fx_sprite.material.get_shader_parameter("noise")
	var noise : FastNoiseLite = n.noise
	
	noise.offset.y += delta
	noise.offset.x += delta
	if Input.is_action_just_released("ui_text_delete"):
		transitioning = true
	if transitioning:
		transition_to_stationary(delta)


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
	
