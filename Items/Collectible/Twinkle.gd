extends Node2D

# A twinkling effect to signify Collectible items on the ground.

var time = 0.0

	
func set_shader_params():
	var fn = FastNoiseLite.new()
	fn.domain_warp_amplitude = 5.0
	fn.frequency = 0.00015
	var x = Utils.player_position.x + global_position.x
	var y = Utils.player_position.y
	var noise = fn.get_noise_2d(x, y)
	material.set_shader_parameter("time", noise*25.0)
	
func _ready():
	set_shader_params()

func _process(_delta):
	time += _delta
	set_shader_params()
