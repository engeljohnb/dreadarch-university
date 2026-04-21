extends Node
class_name Path

enum Shapes
{
	CIRCLE = 0
}

var shape : int = Shapes.CIRCLE
var starting_position : Vector2 = Vector2()
var magnitudes : Array[float] = [1.0]
var _actor : Variant = null
var _speed : float = 10.0
var following : bool = false
var _timer = 0.0
var _eta = 0.0
func follow(actor : Enemy):
	if (actor != null) and (following):
		return
	_actor = actor
	_speed = actor.walk_speed
	following = true
	_timer = 0.0
	_eta = _actor.global_position.distance_to(starting_position) / _speed
	var facing = _actor.facing
	_actor.facing = (starting_position - _actor.global_position).normalized()
	if _actor.facing.is_zero_approx():
		_actor.facing = facing

func _get_velocity() -> Vector2:
	var center = starting_position + Vector2(magnitudes[0], 0.0)
	return (center - _actor.global_position).rotated(deg_to_rad(90.0)).normalized() * _speed
	
func _process_circle():
	_actor.velocity = _get_velocity()
	
# Going by time because checking the position causes bugs I don't understand.
func _arrived_at_starting_position():
	return _timer >= _eta
	
func stop():
	following = false
	_actor = null
	
func _process(_delta):
	if following and (_actor != null):
		_timer += _delta
		if not _arrived_at_starting_position():
			_actor.velocity = (starting_position - _actor.global_position).normalized() * _speed
		else:
			match shape:
				Shapes.CIRCLE:
					_process_circle()
