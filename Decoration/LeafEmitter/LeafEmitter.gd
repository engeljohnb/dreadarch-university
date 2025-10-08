extends Node2D

@export var amount_ratio = 0.5
@export var emitter_length = 128

func _ready() -> void:
	for child in get_children():
		child.amount_ratio = amount_ratio
		child.process_material.emission_shape_scale.x = emitter_length
