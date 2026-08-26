extends Node

const DEBUG_BUILD = true

func error(message : String):
	push_error(message)
	if DEBUG_BUILD:
		breakpoint
	
