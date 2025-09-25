extends Node2D

@warning_ignore("unused_signal")
signal prompt_player(text, on_yes, on_no, yes_text, no_text)
@warning_ignore("unused_signal")
signal open_document()
@warning_ignore("unused_signal")
signal open_dialogue(dialogue : Array[Dictionary])

var current_box = {}
