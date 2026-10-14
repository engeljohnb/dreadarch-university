extends Node

const KEYBOARD_ONLY = 0
const MOUSE = 1

var control_scheme = MOUSE

func rebind(action : String, event : InputEvent):
	InputMap.action_add_event(action, event)
	
