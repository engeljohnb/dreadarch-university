extends Node

var showing_mouse = true

func _process(_delta):
	if get_tree().paused:
		if not showing_mouse:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			showing_mouse = true
	else:
		if showing_mouse:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			showing_mouse = false
