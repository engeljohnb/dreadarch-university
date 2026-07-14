extends Node2D
class_name SoundComponent

var sounds : Dictionary[String, AudioStreamPlayer2D]

func add_sound(sound : Variant, sound_name : String, volume : float):
	if sound is String:
		var player = AudioStreamPlayer.new()
		player.stream = load(sound)
		player.volume_db = volume
		sounds[sound_name] = player
		player.global_position = get_parent().global_position
	if sound is AudioStreamPlayer2D:
		sound.volume_db = volume
		sounds[sound_name] = sound
		sound.global_position = get_parent().global_position
	
	
func get_sound(sound_name) -> Variant:
	return sounds.get(sound_name)
	
	
func _ready():
	var children = get_children()
	for child in children:
		if child is AudioStreamPlayer2D:
			sounds[child.name] = child
	for key in sounds:
		if sounds[key] not in children:
			add_child(sounds[key])
	for child in children:
		child.global_position = get_parent().global_position
			
func stop_sound(sound_name : String):
	var sound : AudioStreamPlayer2D = get_sound(sound_name)
	if sound != null:
		sound.stop()
		
func play_sound(sound_name : String, loop : bool = false):
	var sound : AudioStreamPlayer2D = sounds.get(sound_name)
	if sound != null:
		sound.global_position = get_parent().global_position
		sound.stream.loop = loop
		sound.play()
