extends Event
class_name NotificationEvent
@export var tutorial_key : Variant = ItemCollection.IDs.MAX_TYPES
@export var message : Array
func start():
	Dialogue.dialogue_ended.connect(_set_finished.bind(true))
	if message.is_empty():
		if tutorial_key == ItemCollection.IDs.MAX_TYPES:
			Error.error("No message defined for NotificationEvent")
		else:
			Tutorial.show_message(tutorial_key)
	else:
		Dialogue.notify_player.emit(message)
