extends Button

func _ready():
	pressed.connect(toggle)
	match Controls.control_scheme:
		Controls.KEYBOARD_ONLY:
			text = "Classic"
		Controls.MOUSE:
			text = "Mouse"

func toggle():
	match Controls.control_scheme:
		Controls.KEYBOARD_ONLY:
			text = "Mouse"
			Controls.control_scheme = Controls.MOUSE
		Controls.MOUSE:
			text = "Classic"
			Controls.control_scheme = Controls.KEYBOARD_ONLY
