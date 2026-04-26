extends Node2D

# UP NEXT: For some reason the Twinkles only twinkle
#  If I manually add them to the scene in code. If I just add a
#  collectible, it'll have a Twinkle, and the Twinkle will be in the scene tree,
#  but for some reason it doesn't process.

var time = 0.0
var _player : Variant = null
var _prev_player_position : Vector2

func player_moving() -> bool:
	if _player == null:
		_player = get_tree().get_nodes_in_group("Player")[0]
		_prev_player_position = _player.global_position
	var camera = _player.camera
	var viewport = camera.get_viewport()
	var pos = camera.get_target_position() - (viewport.size/2.0)
	var rect = Rect2(pos, viewport.size)
	var in_viewport = (rect.has_point(global_position))
	
	var _player_moving = (_player.global_position != _prev_player_position)
	_prev_player_position = _player.global_position
	return _player_moving and in_viewport
	
func _ready():
	time += abs(global_position.x*0.0007)
	material.set_shader_parameter("time", time)

func _process(_delta):
	if player_moving():
		material.set_shader_parameter("time", time*2.5)
		time += _delta
