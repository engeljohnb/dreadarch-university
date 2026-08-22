extends Interactable
class_name NPC

var status = {"gone":false}
func check_status(key : String, default : bool = false):
	var s = status.get(key)
	if s == null:
		status[key] = default
		return default
	return s
	
# Implemented by subclasses
func init():
	pass
	
func _ready():
	call_deferred("init")
