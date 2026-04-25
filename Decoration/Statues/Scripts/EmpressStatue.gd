extends Interactable

var inscription = [
	{
		"text":"Regina aeterna sine fine regnet."
	}
]

func _ready():
	interaction_message = "Z to read"
	
func activate(_using_item = "", _count = 0):
	Dialogue.notify_player.emit(inscription)
