extends Node2D


func _ready():
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.facing = Utils.UP
	player.update_animation_blend_positions()
