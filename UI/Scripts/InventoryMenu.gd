extends Control
@onready var item_list = $BookBorder/ItemList
@onready var name_label = $BookBorder/NameLabel
@onready var item_closeup = $BookBorder/ItemCloseup
@onready var submenu = $BookBorder/Submenu
@onready var description_label = $BookBorder/DescriptionLabel
signal inventory_action_chosen(action, item, count)

class InventoryItem:
	var name : String
	var type : int
	var description : String
	var count : int
	var icon : CompressedTexture2D
var inventory_items = []
var submenu_open = false
var number_box_open = false
var chosen_item_name = ""
var chosen_item_type = -1
var chosen_item_total = 0
var chosen_item_count = 0
var chosen_action = ""
var _inventory : Dictionary
var _documents : Array
var document_selector_open = false
var document_items = [ItemCollection.SCROLL_FRAGMENT]
var last_selected_item_index = -1
var just_opened = false
@onready var stupid_submenu = submenu
@onready var box_icons_list = $BookBorder/BoxIcons
var box_icon = load("res://Assets/UI/empty_inventory_slot.png")

func _ready():
	submenu.action_chosen.connect(on_submenu_action_chosen)
	$BookBorder/DocumentSelector.closed.connect(on_document_selector_closed)
	$BookBorder/DocumentSelector.document_used.connect(on_document_used)
	$BookBorder/DocumentSelector.process_mode = Node.PROCESS_MODE_DISABLED
	item_list.item_selected.connect($SelectSound.play)
	get_tree().paused = true
	item_list.grab_focus()
	item_list.clear()
	
func open_submenu():
	submenu.clear()
	submenu.add_button("Use")
	if chosen_item_type in ItemCollection.equippable:
		submenu.add_button("Equip")
	if chosen_item_type in ItemCollection.drinkable:
		submenu.add_button("Drink")
	submenu.add_button("Cancel")
	submenu_open = true
	$OpenSound.play()
	submenu.visible = true
	item_list.deselect_all()
	submenu.select("Use")
	for index in range(0, item_list.item_count):
		item_list.set_item_disabled(index, true)
		
	description_label.visible = false
	
func on_document_used(document):
	inventory_action_chosen.emit("Use", document, 1)
	close()
	
func on_document_selector_closed():
	just_opened = true
	visible = true
	item_list.visible = true
	box_icons_list.visible = true
	item_list.grab_focus()
	item_list.select(last_selected_item_index)
	document_selector_open = false
	$BookBorder/DocumentSelector.visible = false
	$BookBorder/DocumentSelector.process_mode = Node.PROCESS_MODE_DISABLED
	
func open_document_selector(documents):
	$BookBorder/DocumentSelector.process_mode = Node.PROCESS_MODE_INHERIT
	$BookBorder/DocumentSelector.visible = true
	$BookBorder/DocumentSelector.open(documents)
	document_selector_open = true
	item_list.visible = false
	box_icons_list.visible = false
	
func create_count_label(item:InventoryItem):
	var label = RichTextLabel.new()
	label.text =  str(item.count)
	var offset_x = -50#55.0 - 60.0
	var separation = 85
	var width_x = 75.0
	var x_index = inventory_items.size() % item_list.max_columns
	var y_index = int(inventory_items.size() / item_list.max_columns)
	label.add_theme_font_size_override("normal_font_size", 45)
	label.grow_vertical = Control.GROW_DIRECTION_END
	label.offset_top = (separation * y_index) + 70.0
	label.offset_bottom = (separation * y_index) + 70.0
	label.offset_left = offset_x + (x_index * separation)
	label.offset_right = offset_x + (x_index * separation) + width_x
	label.fit_content = true
	label.bbcode_enabled = true
	return label
	
func open(inventory, documents):
	just_opened = true
	inventory_items = []
	for child in item_list.get_children():
		child.queue_free()
	_inventory = inventory
	_documents = documents
	for key in inventory:
		if not ItemCollection.is_item_id_valid(key):
			Error.error("Inventory contains invalid item")
			return
		if inventory[key] > 0:
			var item = InventoryItem.new()
			item.name = ItemCollection.get_string(key)
			item.type = key
			item.icon = ItemCollection.textures[key]
			item.count = inventory[key]
			inventory_items.append(item)
			item_list.add_icon_item(ItemCollection.textures[key])
			var count_label = create_count_label(item)
			item_list.add_child(count_label)
	if _documents.size() > 0:
		var item = InventoryItem.new()
		item.type = ItemCollection.SCROLL_FRAGMENT
		item.name = "Documents"
		item.icon = ItemCollection.textures[ItemCollection.SCROLL_FRAGMENT]
		item.count = _documents.size()
		inventory_items.append(item)
		item_list.add_icon_item(ItemCollection.textures[ItemCollection.SCROLL_FRAGMENT])
		var count_label = create_count_label(item)
		item_list.add_child(count_label)				
	box_icons_list.clear()
	for i in range(0, inventory_items.size()):
		box_icons_list.add_icon_item(box_icon, false)
	var row_size = item_list.max_columns
	var start = inventory_items.size()
	var end = inventory_items.size() + (row_size - (inventory_items.size() % row_size))
	box_icons_list.max_columns = row_size
	for i in range(start, end):
		box_icons_list.add_icon_item(box_icon, false)
		
	if last_selected_item_index > -1:
		item_list.select(last_selected_item_index)
	else:
		item_list.select(0)
	item_list.grab_focus()

func close():
	get_tree().paused = false
	queue_free()

func open_number_box(_max):
	number_box_open = true
	$Numberbox._max = _max
	$Numberbox.visible = true
	submenu.visible = false
	submenu.clear()
	
func close_number_box():
	number_box_open = false
	$Numberbox.visible = false
	
func close_submenu():
	chosen_action = ""
	chosen_item_name = ""
	chosen_item_count = 0
	chosen_item_total = 0
	chosen_item_type = -1
	submenu_open = false
	submenu.clear()
	item_list.clear()
	submenu.visible = false
	description_label.visible = true
		
func on_submenu_action_chosen(action_name):
	chosen_action = action_name
	match chosen_action:
		"Use":
			if chosen_item_total > 1:
				open_number_box(chosen_item_total)
				just_opened = true
			else:
				inventory_action_chosen.emit(chosen_action, chosen_item_type, 1)
				close()
		"Cancel":
			close_submenu()
			open(_inventory, _documents)
		chosen_action:
			inventory_action_chosen.emit(chosen_action, chosen_item_type, 1)
			close()

func _process(_delta):
	if document_selector_open:
		return
	if not submenu_open and not number_box_open:
		if item_list.is_anything_selected():
			var chosen_index = item_list.get_selected_items().get(0)
			last_selected_item_index = chosen_index
			var type = inventory_items[chosen_index].type
			var _name = inventory_items[chosen_index].name
			var icon = inventory_items[chosen_index].icon
			item_closeup.texture = icon
			name_label.text = "[center]" + _name + "[/center]"
			if ItemCollection.descriptions.has(type):
				description_label.text = ItemCollection.descriptions[type]
			else:
				description_label.text = "No description available."
	if Input.is_action_just_released("CloseInventory"):
		if number_box_open:
			close_number_box()
			open_submenu()
		elif submenu_open:
			close_submenu()
			open(_inventory, _documents)
		else:
			if not (just_opened):
				close()
	# This is necessary because the player needs to exit the menu on button release instead
	#  of button press, otherwise they input event will carry out after the menu's closed
	#  and the player will attack or something.
			else:
				just_opened = false
	if Input.is_action_just_released("ui_accept"):
		if just_opened:
			just_opened = false
			return
		if not submenu_open and not number_box_open:
			if item_list.is_anything_selected():
				var chosen_index = item_list.get_selected_items().get(0)
				chosen_item_name = inventory_items[chosen_index].name
				chosen_item_total = inventory_items[chosen_index].count
				chosen_item_type = inventory_items[chosen_index].type
				if chosen_item_type in document_items:
					open_document_selector(_documents)
				else:
					open_submenu()
			return
		elif number_box_open:
			if just_opened:
				just_opened = false
				return
			chosen_item_count = int($Numberbox/RichTextLabel.text)
			if chosen_item_count > 0:
				inventory_action_chosen.emit(chosen_action, chosen_item_type, chosen_item_count)
			close()
