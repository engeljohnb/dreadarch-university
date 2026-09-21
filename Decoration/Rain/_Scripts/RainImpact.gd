extends GPUParticles2D
@onready var animation : AnimatedSprite2D = get_parent().get_node("Animation")
var _timer1 := 0.0
var _timer2 := 0.33
var _timer3 := 0.66
var _frame_time := 1.0/12.0
var _current_frame_1 := 0
var _current_frame_2 := 2
var _current_frame_3 := 4
@export var animation_track := 0
func _set_ar():
	amount_ratio = lerp(0.0, 1.0, WorldTimers.cloud_density)
func update_track_1():
	_current_frame_1 = (_current_frame_1 + 1) % 5
	var frame_1 : Texture2D = animation.sprite_frames.get_frame_texture("01", _current_frame_1)
	var mat : ShaderMaterial = material
	mat.set_shader_parameter("animation_track_1", frame_1)
	
func update_track_2():
	_current_frame_2 = (_current_frame_2 + 1) % 5
	var frame_1 : Texture2D = animation.sprite_frames.get_frame_texture("02", _current_frame_2)
	var mat : ShaderMaterial = material
	mat.set_shader_parameter("animation_track_2", frame_1)
	
func update_track_3():
	_current_frame_3 = (_current_frame_1 + 1) % 5
	var frame_1 : Texture2D = animation.sprite_frames.get_frame_texture("03", _current_frame_3)
	var mat : ShaderMaterial = material
	mat.set_shader_parameter("animation_track_3", frame_1)
	
func _ready():
	material = ShaderMaterial.new()
	material.shader = preload("res://Decoration/Rain/RainImpact.gdshader")
	material.set_shader_parameter("animation_track_id", animation_track)
	update_track_1()
	update_track_2()
	update_track_3()
	
func _process(delta):
	if _timer1 >= _frame_time:
		_timer1 = 0.0
		update_track_1()
	if _timer2 >= _frame_time:
		_timer2 = 0.0
		update_track_2()
	if _timer3 >= _frame_time:
		_timer3 = 0.0
		update_track_3()
	_timer1 += delta
	_timer2 += delta
	_timer3 += delta
