extends Path2D

@onready var path_follow = $PathFollow2D
var pixels_per_second = 75.023
var node_to_move = null

func _ready():
	path_follow.rotates = false
	for node in get_children():
		if node != path_follow:
			node.reparent(path_follow)
			node_to_move = node
	if path_follow.get_child_count() > 0:
		node_to_move = path_follow.get_children()[0]
		
func _process(_delta):
	if node_to_move:
		if "aggrod" in node_to_move:
			if not node_to_move.aggrod:
				path_follow.progress += _delta*pixels_per_second
		else:
			path_follow.progress += _delta*pixels_per_second
