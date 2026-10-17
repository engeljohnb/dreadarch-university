extends Area2D
class_name InteractionMessage
@export var sprite : Sprite2D
@export var interaction_message : Array[String] = []


func _ready():
	if not is_in_group("Interactable"):
		add_to_group("Interactable")
	if sprite != null:
		add_child(sprite)

	
func activate(_using_item = null, _count = 0):
	if not interaction_message.is_empty():
		Dialogue.notify_player.emit(interaction_message)
