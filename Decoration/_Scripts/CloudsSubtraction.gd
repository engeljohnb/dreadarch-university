extends DirectionalLight2D

func _process(_delta):
	if not SceneTransition.scene_is_outside:
		visible = false
	else:
		visible = true
		energy = lerp(0.0, 0.2, WorldTimers.cloud_density)
