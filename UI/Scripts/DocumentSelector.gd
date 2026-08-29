extends Control
signal document_used(document)
signal closed()

var documents = []
var selected_document = {}
# Starts at -2 because next_document is called by open and should set it 
#  to the most recently acquired document
var selected_document_index = -2

func close():
	closed.emit()
	
func on_used():
	document_used.emit(selected_document)
	close()
	
func next_document(index_addend = 1):
	$SelectSound.play()
	if documents.size() < 1:
		return
	selected_document_index += index_addend
	selected_document_index = selected_document_index % documents.size()
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
	
# For some reason, the root DocumentSelector node keeps grabbing the focus
#  and setting focus_mode doesn't stop it.
var _prev_focus : Button
func _stupid_fix_focus():
	if $Use.has_focus():
		_prev_focus = $Use
	elif $Back.has_focus():
		_prev_focus = $Back
	elif has_focus():
		if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
			_prev_focus.grab_focus()
			return
		if _prev_focus == $Use:
			$Back.grab_focus()
		if _prev_focus == $Back:
			$Use.grab_focus()
			
func _process(_delta):
	_stupid_fix_focus()
	if Input.is_action_just_released("CloseInventory"):
		close()
	if Input.is_action_just_pressed("Up"):
		$UpArrow.modulate.a = 0.6
	if Input.is_action_just_pressed("Down"):
		$DownArrow.modulate.a = 0.6
	if Input.is_action_just_released("Up"):
		$UpArrow.modulate.a = 1.0
		next_document()
	if Input.is_action_just_released("Down"):
		$DownArrow.modulate.a = 1.0
		next_document(-1)
