extends Node2D

@warning_ignore("unused_signal")
signal prompt_player(text, on_yes, on_no, yes_text, no_text)
@warning_ignore("unused_signal")
signal open_document()
@warning_ignore("unused_signal")
signal open_dialogue(dialogue : Array[Dictionary])
@warning_ignore("unused_signal")
signal notify_player(note)
@warning_ignore("unused_signal")
signal dialogue_ended

var current_box = {}

func dialogue_open() -> bool:
	return get_tree().get_nodes_in_group("Player")[0].in_dialogue
