extends AudioStreamPlayer

var next_stream = null
var fading_out = false
var fade_out_duration = 1.0
var fade_out_timer = 0.0
var next_volume = 0.0
const MUSIC_DIRECTORY = "res://Music/"

enum {
	DUNGEON_MUSIC,
	INTRO_MUSIC,
	ALCHEMY_LAB_MUSIC,
	DEATH_MUSIC,
	OVERWORLD_MUSIC,
	UNIVERSITY_MUSIC,
	HOME_INTERIOR_MUSIC,
	SHALLOW_RUINS_MUSIC
}
	
var all_tracks = [
	{"name":"DungeonMusic", "path":MUSIC_DIRECTORY + "DungeonMusic.ogg", "volume":-7.3},
	{"name":"IntroMusic", "path":MUSIC_DIRECTORY + "IntroMusic.ogg", "volume":0.0},
	{"name":"AlchemyLabMusic", "path":MUSIC_DIRECTORY + "AlchemyLabMusic.ogg", "volume":0.0},
	{"name":"DeathMusic", "path":MUSIC_DIRECTORY + "DeathMusic.ogg", "volume":0.0},
	{"name":"OverworldMusic", "path":MUSIC_DIRECTORY + "OverworldMusic.ogg", "volume":10.0},
	{"name":"UniversityMusic", "path":MUSIC_DIRECTORY + "UniversityMusic.ogg", "volume":-25.0},
	{"name":"HomeInteriorMusic", "path":MUSIC_DIRECTORY + "HomeInteriorMusic.ogg", "volume":2.0},
	{"name":"ShallowRuinsMusic", "path":MUSIC_DIRECTORY + "ShallowRuinsMusic.ogg", "volume":2.5}
]

var tracks_by_room = [
	{"01-01" : SHALLOW_RUINS_MUSIC},
	{"01-02" : SHALLOW_RUINS_MUSIC},
	{"01-03" : ALCHEMY_LAB_MUSIC},
	{"01-04" : UNIVERSITY_MUSIC},
	{"01-05" : SHALLOW_RUINS_MUSIC},
	{"00-01" : OVERWORLD_MUSIC},
	{"00-02" : OVERWORLD_MUSIC},
	{"00-03" : UNIVERSITY_MUSIC},
	{"00-04" : HOME_INTERIOR_MUSIC},
	{"00-05" : HOME_INTERIOR_MUSIC},
	{"00-06" : OVERWORLD_MUSIC}
]

func get_music_track_from_room_name(room_name : String) -> Dictionary:
	for track in tracks_by_room:
		var track_index = track.get(room_name)
		if track_index != null:
			return all_tracks[track_index]
	Error.error("invalid room name: " + room_name)
	return {}

func transition_to_next(next, _next_volume = volume_db):
	next_stream = next
	next_volume = _next_volume
	fading_out = true
		
func starting_new_music(scene):
	var nm = true
	if stream:
		if stream.resource_path == scene.music:
			nm = false
	return nm
		
func update(current_scene, fade = true, starting_game = false):
	if "music" in current_scene:
		if starting_new_music(current_scene):
			if fade:
				if "music_volume" in current_scene:
					transition_to_next(load(current_scene.music), current_scene.music_volume)
				else:
					transition_to_next(load(current_scene.music), 0.0)
				
			else:
				if "music_volume" in current_scene:
					volume_db = current_scene.music_volume
				stream = load(current_scene.music)
				play()
	if starting_game:
			if current_scene.music.contains("DungeonMusic.ogg"):
				if "music_volume" in current_scene:
					volume_db = current_scene.music_volume
				play(66.36)
	if stream:
		stream.loop = true

func _process(delta):
	if fading_out:
		volume_linear = lerp(volume_linear, 0.0, fade_out_timer*0.05)
		fade_out_timer += delta
		if fade_out_timer >= fade_out_duration:
			fading_out = false
			fade_out_timer = 0.0
			stream = next_stream
			volume_db = next_volume
			play()
