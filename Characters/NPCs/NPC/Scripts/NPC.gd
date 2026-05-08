extends Interactable
class_name NPC

var status = {"gone":false}
# Implemented by subclasses

func init():
	pass
func _ready():
	interaction_message = "Z to talk"
	call_deferred("init")
