extends Event
class_name WalkEvent

var target_position : Vector2
var duration : float

func start():
	get_tree().get_first_node_in_group("Player").walk_to(target_position, duration)

func is_finished() -> bool:
	var player = get_tree().get_first_node_in_group("Player")
	return !player.in_cutscene
func end():
	pass
