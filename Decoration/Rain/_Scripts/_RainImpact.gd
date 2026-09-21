extends Node2D

@onready var animation : AnimatedSprite2D = $Animation
@onready var sprite : Sprite2D = $Impact

var current_frame : int = 0
var timer : float = 0.0
const frame_time : float = 1.0/12.0

func _ready():
	update_frames()

func update_frames():
	var frame_1 : Texture2D = animation.sprite_frames.get_frame_texture("01", current_frame)
	var frame_2 : Texture2D = animation.sprite_frames.get_frame_texture("02", current_frame)
	var frame_3 : Texture2D = animation.sprite_frames.get_frame_texture("03", current_frame)
	
	sprite.material.set_shader_parameter("animation_frames[0]", frame_1)
	sprite.material.set_shader_parameter("animation_frames[1]", frame_2)
	sprite.material.set_shader_parameter("animation_frames[2]", frame_3)

func _process(delta):
	timer += delta
	if timer >= frame_time:
		current_frame = (current_frame + 1) % 5
		update_frames()
		timer = 0.0
	print(timer)
