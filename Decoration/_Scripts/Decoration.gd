extends Area2D
class_name Decoration
@export var sprite : Sprite2D
@export var interaction_message : Array[String] = []
@export var interaction_dialogue : Array[Dictionary] = []

var _int_msg : Array[Dictionary]

func _ready():
	if not is_in_group("Interactable"):
		add_to_group("Interactable")
	for i in range(0,interaction_message.size()):
		if i == 0:
			_int_msg.append({"text" : interaction_message[i]})
		else:
			_int_msg.append({"text " + str(i) : interaction_message[i]})
	if sprite != null:
		add_child(sprite)

	
func activate(_using_item = null, _count = 0):
	if not interaction_message.is_empty():
		breakpoint
		Dialogue.notify_player.emit(_int_msg)
	elif not interaction_dialogue.is_empty():
		Dialogue.open_dialogue.emit(interaction_dialogue)
#
