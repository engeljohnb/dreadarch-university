extends Control
signal document_used(document)
signal closed()

var documents = []
var selected_document = {}
var selected_document_index = -1

func close():
	closed.emit()
	queue_free()
	
func on_used():
	document_used.emit(selected_document)
	queue_free()
	
func next_document(index_addend = 1):
	$SelectSound.play()
	if documents.size() < 1:
		return
	selected_document_index += index_addend
	if selected_document_index >= documents.size():
		selected_document_index = 0
	if selected_document_index < 0:
		selected_document_index = documents.size()-1
	selected_document = documents[selected_document_index]
	if selected_document["translated"]:
		$RichTextLabel.text = selected_document["english_text"]
	else:
		$RichTextLabel.text = selected_document["latin_text"]
	
func open(_documents):
	documents = _documents
	visible = true
	next_document()
	$Use.grab_focus()

func _ready():
	$Use.pressed.connect(on_used)
	$Back.pressed.connect(close)
	$Use.grab_focus()
	
func _process(_delta):
	if Input.is_action_just_pressed("CloseInventory"):
		close()
	if Input.is_action_just_pressed("Up"):
		$UpArrow.modulate.a = 0.6
		next_document()
	if Input.is_action_just_pressed("Down"):
		$DownArrow.modulate.a = 0.6
		next_document(-1)
	if Input.is_action_just_released("Up"):
		$UpArrow.modulate.a = 1.0
	if Input.is_action_just_released("Down"):
		$DownArrow.modulate.a = 1.0
