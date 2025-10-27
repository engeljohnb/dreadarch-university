extends AudioStreamPlayer

var next_stream = null
var fading_out = false
var fade_out_duration = 1.0
var fade_out_timer = 0.0
var next_volume = 0.0

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
