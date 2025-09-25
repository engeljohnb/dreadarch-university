extends Node
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0,1)
const DOWN = Vector2(0,-1)

func nearest_cardinal_direction(direction : Vector2, as_text = false):
	var x = direction.x
	var y = direction.y
	if (abs(x) > abs(y)):
		if (x < 0):
			if as_text:
				return "Left"
			else:
				return LEFT
		else:
			if as_text:
				return "Right"
			else:
				return RIGHT
	else:
		if (y < 0):
			if as_text:
				return "Up"
			else:
				return UP
		else:
			if as_text:
				return "Down"
			else:
				return DOWN
