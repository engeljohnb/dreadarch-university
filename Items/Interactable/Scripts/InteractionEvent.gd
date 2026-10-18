extends Interactable
class_name EventInteractable

# Why why why not have Array[Events] so I can have more than one at a time?
#	Because for some reason when I try to assign
#	one of the elements in the editor, Godot says 
#	"Attempted to set an object into a TypedArray, that does not inherit from 'GDScript'"
#	No idea why it doesn't want me to do that.
@export var event: Event
# This is relative -- not global coordinates.
@export var target_position : Vector2
var event_sequence : EventSequence = EventSequence.new()

func _ready():
	event_sequence.free_on_finish = false
	
func add_main_event():
	event_sequence.add_event(event)
	if event_sequence.get_parent() != self:
		add_child(event_sequence)
		
func activate(_using_item = null, _count = 0):
	if target_position:
		if not Utils.player_in_touching_distance():
			var pos = global_position + target_position
			var duration = Utils.get_walk_duration(pos)
			event_sequence.add_walk_event(pos, duration)
	add_main_event()
	event_sequence.start_events()
