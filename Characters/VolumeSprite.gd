extends AnimatedSprite2D
class_name VolumeSprite

@export var target : AnimatedSprite2D
var default_value : float = 0.66
#func _ready():
#	Engine.time_scale = 0.033

func _process(_delta):
	if (target == null) or (sprite_frames == null):
		Error.error("Missing data for VolumeSprite")
		return
	var _frame : int = target.frame
	var mat : ShaderMaterial = target.material
	var texture : Texture2D = sprite_frames.get_frame_texture(get_animation_name(), _frame)
	mat.set_shader_parameter("bump_map", texture)

func set_default_value():
	target.material.set_shader_parameter("baseline", default_value)

func get_animation_name() -> StringName:
	if sprite_frames.has_animation(target.animation):
		return target.animation
	else:
		return "Idle Down"
		
