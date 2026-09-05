extends Event
class_name DialogueEvent

@export var dialogue : Array
func start():
	Dialogue.dialogue_ended.connect(_set_finished.bind(true))
	Dialogue.open_dialogue.emit(dialogue)
func end():
	Dialogue.current_ui_box.end()
