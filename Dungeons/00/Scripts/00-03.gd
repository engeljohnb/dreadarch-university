extends Node2D
@export var music = "res://Music/UniversityMusic.ogg"
@export var music_volume = -25.00

func _ready():
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.facing = Utils.UP
	player.update_animation_blend_positions()
