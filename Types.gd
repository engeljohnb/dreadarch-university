extends Node
const POT = "Pot"
const NPC = "NPC"
const OTHER = "Other"

class Room:
	extends Node2D
	@export var music : String = "res://Music/DungeonMusic.ogg"
	@export var music_volume : float = -7.3
	var save_data : Dictionary = {
		"pots":[],
		"NPCs":[],
		"items":{Collectible.TREASURE:[]}
	}
	func _ready():
		var music_track = Music.get_music_track_from_room_name(SceneTransition.current_scene_name)
		if not music_track.is_empty():
			music = music_track["path"]
			music_volume = music_track["volume"]
