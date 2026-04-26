extends Node2D

# A twinkling effect to signify Collectible items on the ground.

var time = 0.0
var _player : Variant = null
var _prev_player_position : Vector2

func _init_player():
	_player = get_tree().get_nodes_in_group("Player")[0]
	_prev_player_position = _player.global_position
	
func set_shader_params():
	if _player == null:
		return
	var fn = FastNoiseLite.new()
	fn.domain_warp_amplitude = 5.0
	fn.frequency = 0.00015
	var x = _player.global_position.x + global_position.x
	var y = _player.global_position.y
	var noise = fn.get_noise_2d(x, y)
	material.set_shader_parameter("time", noise*25.0)
	
func _ready():
	_init_player()
	set_shader_params()
	set_shader_params()

func _process(_delta):
	time += _delta
	set_shader_params()
