class_name ViewDocumentEvent
extends Event

func start():
	Dialogue.dialogue_ended.connect(_set_finished.bind(true))
	Dialogue.open_document.emit()
