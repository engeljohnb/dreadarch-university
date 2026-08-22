extends Node2D

@export var inactive_modulate = 0.33
@export var active_modulate = 1.0
@onready var label = $RichTextLabel
@onready var border = $Border
@onready var area = $Decoration
@onready var icon = $InteractionIcon
var player = null

func brighten():
	modulate.a = active_modulate
	label.visible = true
	border.visible = true
	
func darken():
	modulate.a = inactive_modulate
	label.visible = false
	border.visible = false

func _process(_delta):
	if player == null:
		player = get_tree().get_nodes_in_group("Player")[0]
	if player.interaction_ray.get_collider() == area:
		brighten()
	else:
		darken()
