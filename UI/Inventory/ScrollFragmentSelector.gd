extends Control

signal action_chosen(action, item, count)
signal closed
var documents : Array[Dictionary]
var focused_index = 0
@onready var item_list = $ItemList
@onready var item_text = $RichTextLabel

func _ready():
	documents = get_tree().get_first_node_in_group("Player").documents
	item_list.clear()
	item_list.item_activated.connect($Use.grab_focus)
	$Use.pressed.connect(on_used)
	$Cancel.pressed.connect(on_cancel)
	populate_item_list()
	$ItemList.focus_entered.connect(func (): $ItemList.select(focused_index))
	item_list.grab_focus()

func on_used():
	var action = "Use"
	var item = get_selected_document()
	action_chosen.emit(action, item, 1)
	close()
	
func on_cancel():
	item_list.grab_focus()
	item_list.grab_click_focus()
	
func get_text(document : Dictionary):
	if document["translated"]:
		return document["english_text"]
	else:
		return document["latin_text"]

func get_selected_document() -> Dictionary:
	var selected_items : Array = item_list.get_selected_items()
	if selected_items.is_empty():
		return {}
	var index : int = selected_items[0]
	return documents[index]
	
func add_document(document : Dictionary):
	var tex = ItemCollection.textures[ItemCollection.SCROLL_FRAGMENT]
	item_list.add_item(get_text(document), tex)

func populate_item_list():
	for document in documents:
		add_document(document)

func show_item(document : Dictionary):
	item_text.text = get_text(document)
	
func _process(_delta):
	var selected_document : Dictionary = get_selected_document()
	focused_index = $ItemList.get_selected_items()[0]
	if selected_document.is_empty():
		$Use.disabled = true
	else:
		show_item(selected_document)
		$Use.disabled = false

func close():
	closed.emit()
