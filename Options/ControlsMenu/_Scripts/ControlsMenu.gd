extends Control
signal closed()

func _process(_delta):
	if Input.is_action_just_pressed("UI Cancel"):
		queue_free()
		closed.emit()
