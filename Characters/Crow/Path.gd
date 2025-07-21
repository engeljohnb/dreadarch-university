extends Path2D
var current_point_index = 0

func get_next_point(current_position, delta, speed):
	if (current_position.distance_to(curve.get_point_position(current_point_index)) <= delta*speed):
		current_point_index += 1
		if current_point_index >= curve.point_count:
			current_point_index = 0
	return curve.get_point_position(current_point_index)
