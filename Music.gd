extends Node
const MUSIC_DIRECTORY = "res://Music/"

enum {
	DUNGEON_MUSIC,
	INTRO_MUSIC,
	ALCHEMY_LAB_MUSIC,
	DEATH_MUSIC,
	OVERWORLD_MUSIC,
	UNIVERSITY_MUSIC,
}
	
var all_tracks = [
	{"name":"DungeonMusic", "path":MUSIC_DIRECTORY + "DungeonMusic.ogg", "volume":-7.3},
	{"name":"IntroMusic", "path":MUSIC_DIRECTORY + "IntroMusic.ogg", "volume":0.0},
	{"name":"AlchemyLabMusic", "path":MUSIC_DIRECTORY + "AlchemyLabMusic.ogg", "volume":0.0},
	{"name":"DeathMusic", "path":MUSIC_DIRECTORY + "DeathMusic.ogg", "volume":0.0},
	{"name":"OverworldMusic", "path":MUSIC_DIRECTORY + "OverworldMusic.ogg", "volume":10.0},
	{"name":"UniversityMusic", "path":MUSIC_DIRECTORY + "UniversityMusic.ogg", "volume":-25.0}
]

var tracks_by_room = [
	{"01-01" : DUNGEON_MUSIC},
	{"01-02" : DUNGEON_MUSIC},
	{"01-03" : ALCHEMY_LAB_MUSIC},
	{"01-04" : UNIVERSITY_MUSIC},
	{"00-01" : OVERWORLD_MUSIC},
	{"00-02" : OVERWORLD_MUSIC},
	{"00-03" : UNIVERSITY_MUSIC}
]

func get_music_track_from_room_name(room_name : String) -> Dictionary:
	for track in tracks_by_room:
		var track_index = track.get(room_name)
		if track_index != null:
			return all_tracks[track_index]
	print("get_music_track_from_room_name ERROR: invalid room name: ", room_name)
	return {}
