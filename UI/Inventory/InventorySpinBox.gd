extends SpinBox
var choosing_number = true
var awaiting_confirmation = false
func _ready():
	$Cancel.pressed.connect(close)
	
func enable():
	choosing_number = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	focus_mode = FOCUS_ALL
	$Accept.focus_mode = FOCUS_ALL
	$Cancel.focus_mode = FOCUS_ALL
	
func disable():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	focus_mode = FOCUS_NONE
	$Accept.focus_mode = FOCUS_NONE
	$Cancel.focus_mode = FOCUS_NONE

func close():
	choosing_number = true
	disable()
	get_parent().grab_focus()
	
func _process(_delta):
	if not Controls.can_use_mouse:
		if choosing_number:
			grab_focus()
			if Input.is_action_just_pressed("ui_up"):
				value = int(value + 1) % int(max_value)
			elif Input.is_action_just_pressed("ui_down"):
				value = int(value - 1) % int(max_value)
		else:
			if not awaiting_confirmation:
				$Cancel.grab_focus()
				awaiting_confirmation = true
	Error.set_breakpoint()

func _gui_input(event: InputEvent):
	if event.is_action_released("UI Accept"):
		if value > 0.0:
			if event is not InputEventMouseButton:
				choosing_number = false
				accept_event()
	if event.is_action_released("UI Cancel"):
		accept_event()
		close()
