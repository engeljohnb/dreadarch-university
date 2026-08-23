class_name Event
extends Node

var _finished : bool = false
@warning_ignore("unused_private_class_variable")
var _started := false
func _set_finished(state : bool):
	breakpoint
	_finished = state
func is_finished() -> bool:
	return _finished
func start():
	pass
func end():
	queue_free()
func _process(_delta : float) -> void:
	pass
