extends Node2D

func _process(_delta):
	var num_enemies = get_tree().get_nodes_in_group("Enemies").size()
	if num_enemies == 0:
		SceneTransition.win()
