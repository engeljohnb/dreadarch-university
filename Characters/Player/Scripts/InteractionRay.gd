extends RayCast2D

var message_showing = false
var _message = load("res://UI/InteractionMessage.tscn")
var message = null
var temp_message = ""
var using_item = ""
var using_item_count = 1
func show_message(text, _position):
	message = _message.instantiate()
	message.text = text
	if not temp_message.is_empty():
		message.text = temp_message
	add_child(message)
	
func hide_message():
	if message:
		message.queue_free()

func _process(_delta):
	if is_colliding():
		var col = get_collider()
		if col.is_in_group("Interactable"):
			if not message_showing:
				if "interaction_message" in col:
					show_message(col.interaction_message, col.position)
				else:
					show_message("Z to interact", col.position)
				message_showing = true
		else:
			if message_showing:
				hide_message()
				message_showing = false
		if message_showing:
			if Input.is_action_just_released("Interact"):
				if not get_parent().in_dialogue:
					if "activate" in col:
						if not using_item.is_empty():
							col.activate(using_item, using_item_count)
							using_item = ""
							temp_message = ""
						else:
							col.activate()
	else:
		if message_showing:
			hide_message()
			message_showing = false
			
