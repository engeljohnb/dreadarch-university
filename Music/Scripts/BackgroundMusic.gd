extends AudioStreamPlayer

func _process(_delta):
	if get_tree().paused:
		volume_db = -7.0
	else:
		volume_db = 0.0
