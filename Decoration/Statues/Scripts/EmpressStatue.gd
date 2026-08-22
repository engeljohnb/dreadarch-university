extends Interactable

var inscription = [
	{
		"text":"Regina aeterna sine fine regnet."
	}
]

	
func activate(_using_item : Variant = null, _count = 0):
	Dialogue.notify_player.emit(inscription)
