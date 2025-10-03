extends Node2D

@export var player_start_position : Vector2

@export var music = "res://Music/DungeonMusic.ogg"

var save_info = {
	"pots":[],
	"NPCs":[],
	"items":{Collectible.TREASURE:[]}
	}
