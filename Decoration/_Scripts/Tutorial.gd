extends InteractionMessage

func get_text():
	return Tutorial.get_controller_icon_string("Click") + " to search things, interact with things, or talk to people."
	
func activate(_using_item = null, _count = 0):
	Dialogue.notify_player.emit([get_text()])
