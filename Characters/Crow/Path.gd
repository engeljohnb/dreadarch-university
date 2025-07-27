extends Path2D
var current_point_index = 0

func _ready():
	var start_pos = get_parent().global_position
	for i in range(0, curve.point_count):
		curve.set_point_position(i, curve.get_point_position(i)+start_pos)

func get_next_point(current_position, delta, speed):
	if (current_position.distance_to(curve.get_point_position(current_point_index)) <= delta*speed):
		print(curve.get_point_position(current_point_index))
		current_point_index += 1
		if current_point_index >= curve.point_count:
			current_point_index = 0
	return curve.get_point_position(current_point_index)
