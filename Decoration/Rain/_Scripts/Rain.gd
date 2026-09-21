extends Node2D

func disable():
	$GPUParticles2D.emitting = false
	$GPUParticles2D2.emitting = false
	$GPUParticles2D3.emitting = false
	$GPUParticles2D4.emitting = false
func enable():
	$GPUParticles2D.emitting = true
	$GPUParticles2D2.emitting = true
	$GPUParticles2D4.emitting = true
	$GPUParticles2D3.emitting = true
	
func _ready():
	on_new_scene()
	SceneTransition.new_scene.connect(on_new_scene)
		
func on_new_scene():
	if not SceneTransition.scene_is_outside:
		disable()
	else:
		if WorldTimers.is_raining:
			enable()
		else:
			disable()
			
func update():
	var part : GPUParticles2D = $GPUParticles2D2
	part.amount_ratio = lerp(0.0, 1.0, WorldTimers.cloud_density)
	
func _process(_delta):
	if WorldTimers.is_raining:
		if SceneTransition.scene_is_outside:
			enable()
		update()
	else:
		disable()
