extends Node

const DEBUG_BUILD = true

func error(message : String):
	push_error(message)
	if DEBUG_BUILD:
		breakpoint
func print_to_screen(message : String):
	var label : RichTextLabel = get_tree().get_nodes_in_group("Debug")[0]
	label.text = message
func set_breakpoint():
	if Input.is_action_just_pressed("ui_text_backspace"):
		breakpoint
	
