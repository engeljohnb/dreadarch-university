extends Node2D

@export var amount_ratio = 0.5
@export var emitter_length = 128

func disable():
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = false
			
func enable():
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = true
			
func _ready() -> void:
	for child in get_children():
		child.amount_ratio = amount_ratio
		child.process_material.emission_shape_scale.x = emitter_length
	if WorldTimers.is_raining:
		disable()
	else:
		enable()
	
