extends Node

var _default_state : Dictionary = {
	"seen_by_verina" = false,
	"weather_timer" = 0.0
}
var state : Dictionary = _default_state

func reset():
	state = _default_state
