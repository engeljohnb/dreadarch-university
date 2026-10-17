extends Control
signal closed()
func _ready():
	$TabContainer/Presets.closed.connect(close)

func close():
	queue_free()
	closed.emit()
func _process(_delta):
	if Input.is_action_just_pressed("UI Cancel"):
		close()
