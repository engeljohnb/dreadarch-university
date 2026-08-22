extends Room
var _showing_letter = false

func _on_letter_closed():
	_showing_letter = false
	modulate.a = 1.0
	Tutorial.messages_shown["letter_from_professor"] = true

func show_professor_letter():
	Dialogue.open_letter.emit()
	Dialogue.dialogue_ended.connect(_on_letter_closed)
	modulate.a = 0.33
	_showing_letter = true
	
func _ready():
	if not Tutorial.message_shown("letter_from_professor"):
		show_professor_letter()
