extends Button

func _ready():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		text = "Visible"
	else:
		text = "Hidden"
	pressed.connect(on_pressed)
	
func on_pressed():
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		text = "Visible"
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		text = "Hidden"
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
