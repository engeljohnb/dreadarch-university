extends Node
class_name EnemySoundComponent
# sounds should be int : AudioStream, but for some reason
#  When I load the .ogg files, godot loads them as "Object" not "AudioStream"
#  So just be careful to use the right types.

# A dict for which ActorSounds correspond to each action. Enemy state machine 
#  just passes the current state (action) to update
#  Use Enemy.Actions enum
@export var sounds : Dictionary[int, ActorSound]

var _delayed_sounds : Array[ActorSound]
var _prev_action : int

func set_bus(bus : StringName):
	$AudioStreamPlayer2D.bus = bus
	
func set_volume(volume : float):
	$AudioStreamPlayer2D.volume_db = volume
	
func should_play_sound(sound) -> bool:
	if (sound.played and sound.play_only_once):
		return false
	return (not sound.played) or sound.looping
	
func play_sound(sound : ActorSound):
	$AudioStreamPlayer2D.stream = sound.stream
	$AudioStreamPlayer2D.volume_db = sound.volume
	$AudioStreamPlayer2D.play()
	sound.played = true
	
func _init_new_action(current_action : int, sound : ActorSound):
	if current_action != _prev_action:
		if not sound.play_only_once:
			sound.played = false
		_delayed_sounds = []
		delay_timer = 0.0
			
func update(current_action : int):
	var sound = sounds.get(current_action)
	if is_inside_tree() and (sound != null):
		_init_new_action(current_action, sound)
		if should_play_sound(sound):
			if sound.delay == 0.0:
				play_sound(sound)
			else:
				_delayed_sounds.append(sound)
	_prev_action = current_action
	
var delay_timer = 0.0
func _process(delta : float):
	$AudioStreamPlayer2D.global_position = get_parent().global_position
	for sound in _delayed_sounds:
		if delay_timer >= sound.delay:
			play_sound(sound)
			_delayed_sounds.erase(sound)
	delay_timer += delta
			
		
