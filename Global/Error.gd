extends Node

const DEBUG_BUILD = true

func error(message : String):
	push_error(message)
	if DEBUG_BUILD:
		breakpoint
		
func set_breakpoint():
	if Input.is_action_just_pressed("ui_text_backspace"):
		breakpoint
	
