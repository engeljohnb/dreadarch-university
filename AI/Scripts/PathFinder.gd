extends Node2D
class_name PathFinder
enum Orders
{
	CHASE,
	PATROL
}
static var _my_node = preload("res://AI/PathFinder.tscn")
var order : int = Orders.CHASE
var chase_target : Variant
var facing : Vector2
@onready var raycast = $RayCast2D
var sight_range := 70.0
var parent : Variant

static func create() -> PathFinder:
	var node : PathFinder = _my_node.instantiate()
	return node
	
func set_orders_chase(target : Variant):
	order = Orders.CHASE
	chase_target = target
	
func process_orders_chase() -> Vector2:
	if chase_target == null:
		return (Utils.player_position - global_position).normalized()
	return (chase_target.global_position - global_position).normalized()
	
func set_orders_patrol(_parent : Variant, range_of_sight := 70.0):
	parent = _parent
	order = Orders.PATROL
	sight_range = range_of_sight
	
var _timer := 0.0
var _counting := false
func standing_still() -> bool:
	if not parent.moving():
		if not _counting:
			_counting = true
			_timer = 0.0
		if _counting and (_timer >= 0.66):
			_counting = false
			_timer = 0.0
			return true
	return false
	
func process_orders_patrol() -> Vector2:
	if facing.is_zero_approx():
		facing = Vector2(-1, 0)
	raycast.target_position = facing * sight_range
	if raycast.is_colliding():
		facing = facing.rotated(-PI/4.0)
	if standing_still():
		facing = facing.rotated(-PI/8.0)
	return facing
	
func get_direction() -> Vector2:
	var dir := Vector2()
	match order:
		Orders.CHASE:
			dir = process_orders_chase()
		Orders.PATROL:
			dir = process_orders_patrol()
		order:
			push_warning("Invalid Pathfinder order ID: ", order)
			dir = Vector2(1,0)
	return dir

func _process(_delta):
	_timer += _delta
