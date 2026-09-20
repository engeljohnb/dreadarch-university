extends Node

var _default_state : Dictionary = {
	"seen_by_verina" = false
}
var state : Dictionary = _default_state

func reset():
	state = _default_state
