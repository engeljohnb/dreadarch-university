extends Node

const DEBUG_BUILD = false

func error(message : String):
	push_error(message)
	if DEBUG_BUILD:
		breakpoint
	
