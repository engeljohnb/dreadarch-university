extends Node2D

func _process(_delta):
	if get_tree().get_nodes_in_group("Enemies").is_empty():
		SceneTransition.won.emit()
