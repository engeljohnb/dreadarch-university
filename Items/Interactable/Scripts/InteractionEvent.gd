extends Interactable
class_name EventInteractable

# Why why why not have Array[Events] so I can have more than one at a time?
#	Because for some reason when I try to assign
#	one of the elements in the editor, Godot says 
#	"Attempted to set an object into a TypedArray, that does not inherit from 'GDScript'"
#	No idea what it means.
@export var event: Event
var event_sequence : EventSequence = EventSequence.new()

func _ready():
	event_sequence.free_on_finish = false
	
func activate(_using_item = null, _count = 0):
	event_sequence.add_event(event)
	if event_sequence.get_parent() != self:
		add_child(event_sequence)
	event_sequence.start_events()
