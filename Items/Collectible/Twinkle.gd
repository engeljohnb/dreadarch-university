extends Node2D

# UP NEXT: For some reason the Twinkles only twinkle
#  If I manually add them to the scene in code. If I just add a
#  collectible, it'll have a Twinkle, and the Twinkle will be in the scene tree,
#  but for some reason it doesn't process.

var time = 0.0
# This is so each instance twinkles differently
var _player : Variant = null


func player_moving() -> bool:
	if _player == null:
		_player = get_tree().get_nodes_in_group("Player")[0]
	var camera = _player.camera
	var viewport = camera.get_viewport()
	var pos = camera.get_target_position() - (viewport.size/2.0)
	var rect = Rect2(pos, viewport.size)
	var in_viewport = (rect.has_point(global_position))
	
	return _player.moving and in_viewport

func _process(_delta):
	if player_moving():
		var fn = FastNoiseLite.new()
		fn.domain_warp_amplitude = 15.0
		fn.frequency = 0.01
		var noise = FastNoiseLite.new().get_noise_1d(time)
		material.set_shader_parameter("time", noise*350.0)
		time += _delta
