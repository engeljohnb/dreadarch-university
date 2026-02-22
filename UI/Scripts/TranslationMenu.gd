extends Control
signal closed()
var documents = []
var selected_document = {}
var selected_document_index = -1
var safe_to_close = false
var _trans_prog = load("res://UI/TranslationProgress.tscn")
var _level_up_menu = load("res://UI/LevelUpMenu.tscn")
var level_up_menu = null
var progress_icons = []
var starting_scroll_position = Vector2(570, 400)
var progress_index = 0
var level_up_open = false

func close():
	get_tree().paused = false
	closed.emit()
	queue_free()
	
func on_closed():
	$Back.grab_focus()
	visible = true
	level_up_open = false
	
func on_translate():
	if selected_document.is_empty():
		Dialogue.notify_player.emit([{"text":"Nothing to translate."}])
		closed.emit()
		queue_free()
		return
	if selected_document["translated"]:
		return
	selected_document["translated"] = true
	$RichTextLabel.text = selected_document["english_text"]
	progress_icons[progress_index].fill()
	progress_index += 1
	Collectible.scroll_fragment_translated.emit(selected_document)
	if progress_index == Collectible.fragments_to_level_up:
		level_up_menu = _level_up_menu.instantiate()
		visible = false
		add_sibling(level_up_menu)
		level_up_open = true
		level_up_menu.closed.connect(on_closed)
	if progress_index > Collectible.fragments_to_level_up:
		progress_index = 0
		for icon in progress_icons:
			icon.reset()
	
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
	$OpenSound.play()
	get_tree().paused = true
	documents = _documents
	visible = true
	next_document()
	var num_translated = 0
	for document in documents:
		if document.get("translated"):
			num_translated += 1
	var width = (Collectible.fragments_to_level_up)*84
	for i in range(0, Collectible.fragments_to_level_up):
		var icon = _trans_prog.instantiate()
		icon.z_index = 11
		progress_icons.append(icon)
		$TextureRect.add_sibling(icon)
		icon.position.y = starting_scroll_position.y
		icon.position.x = starting_scroll_position.x + (width/2.0) + (i*84)
		if i < (num_translated%Collectible.fragments_to_level_up):
			progress_index += 1
			icon.set_full()
		
		
	$Translate.grab_focus()

func _ready():
	$Translate.pressed.connect(on_translate)
	$Back.pressed.connect(close)
	$Translate.grab_focus()
	$RichTextLabel.text = ""
	
func _process(_delta):
	if level_up_open:
		return
	if Input.is_action_just_released("CloseInventory"):
		if not safe_to_close:
			safe_to_close = true
			return
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
