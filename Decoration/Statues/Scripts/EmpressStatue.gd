extends StaticBody2D

var type = Types.OTHER
var interaction_message = "Z to read"
var inscription = [
	{
		"text":"Regina aeterna sine fine regnet."
	}
]

func activate(_using_item = "", _count = 0):
	Dialogue.notify_player.emit(inscription)
