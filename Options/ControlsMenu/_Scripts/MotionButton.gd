extends Button
class_name MotionRemapButton

var free_description := "Crosshairs can be controlled with mouse or joystick"
var fixed_description := "Crosshairs follow player. Recommended for keyboard-only or gamepad"
func _ready():
	pressed.connect(toggle)
	update_button_text()
	
func update_button_text():
	match Controls.control_scheme:
		Controls.FIXED_CROSSHAIRS:
			text = "Fixed"
			$RichTextLabel.text = fixed_description
		Controls.FREE_CROSSHAIRS:
			text = "Free"
			$RichTextLabel.text = free_description
func toggle():
	match Controls.control_scheme:
		Controls.FIXED_CROSSHAIRS:
			text = "Free"
			Controls.control_scheme = Controls.FREE_CROSSHAIRS
			$RichTextLabel.text = free_description
		Controls.FREE_CROSSHAIRS:
			text = "Fixed"
			Controls.control_scheme = Controls.FIXED_CROSSHAIRS
			$RichTextLabel.text = fixed_description
