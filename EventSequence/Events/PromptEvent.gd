extends Event
class_name PromptEvent

@export var message : String
@export var on_yes : Callable
@export var on_no : Callable
@export var yes_text : String = "Yes"
@export var no_text : String = "No"
func start():
	Dialogue.dialogue_ended.connect(_set_finished.bind(true))
	Dialogue.prompt_player.emit(message, on_yes, on_no, yes_text, no_text)
	
