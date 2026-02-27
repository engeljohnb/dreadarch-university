extends Control
@onready var item_list = $BookBorder/ItemList
@onready var name_label = $BookBorder/NameLabel
@onready var item_closeup = $BookBorder/ItemCloseup
@onready var submenu = $BookBorder/Submenu
@onready var description_label = $BookBorder/DescriptionLabel
signal inventory_action_chosen(action, item, count)

class InventoryItem:
	var name : String
	var description : String
	var count : int
	var icon : CompressedTexture2D
var inventory_items = []
var submenu_open = false
var number_box_open = false
var chosen_item_name = ""
var chosen_item_total = 0
var chosen_item_count = 0
var chosen_action = ""
var _inventory : Dictionary
var document_selector_open = false
var document_items = [Collectible.SCROLL_FRAGMENT]
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
	#Doing this weird little dance fixes a bug where the arrow keys sometimes
		# Don't change which button is selected in the submenu.
	#stupid_submenu.queue_free()
	#stupid_submenu = submenu.duplicate()
	#submenu.queue_free()
	#submenu = stupid_submenu.duplicate()
	#$BookBorder.add_child(submenu)
	
	submenu.clear()
	submenu.add_button("Use")
	if chosen_item_name in Collectible.equippable:
		submenu.add_button("Equip")
	if chosen_item_name in Collectible.drinkable:
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
	#var doc_sel = load("res://UI/DocumentSelector.tscn").instantiate()	
	#add_sibling(doc_sel)
	$BookBorder/DocumentSelector.open(documents)
	#visible = false
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
	
func open(inventory):
	just_opened = true
	inventory_items = []
	for child in item_list.get_children():
		child.queue_free()
	_inventory = inventory
	for key in inventory:
		if key.is_empty():
			continue
		if (inventory[key] is int) or (inventory[key] is float):
			if inventory[key] > 0:
				var item = InventoryItem.new()
				item.name = key
				item.icon = Collectible.textures[key]
				item.count = int(inventory[key])
				inventory_items.append(item)
				item_list.add_icon_item(Collectible.textures[key])
				var count_label = create_count_label(item)
				item_list.add_child(count_label)
		elif inventory[key] is Array:
			if inventory[key].size() > 0:
				var type = inventory[key][0].get("type")
				if type:
					match type:
						"Scroll Fragment":
							var item = InventoryItem.new()
							item.name = "Scroll Fragment"
							item.icon = Collectible.textures[key]
							item.count = inventory[key].size()
							inventory_items.append(item)
							item_list.add_icon_item(Collectible.textures[key])
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
	#var offset_distance = $Numberbox.offset_top - $Numberbox.offset_bottom
	#if submenu.is_anything_selected():
	#	$Numberbox.offset_top = submenu.get_item_rect(submenu.get_selected_items().get(0)).position.y
	#	$Numberbox.offset_bottom = $Numberbox.offset_top + offset_distance
	$Numberbox.visible = true
	submenu.visible = false
	submenu.clear()
	#for index in range(0, submenu.item_count):
	#	submenu.set_item_disabled(index, true)
	
func close_number_box():
	number_box_open = false
	$Numberbox.visible = false
	
func close_submenu():
	chosen_action = ""
	chosen_item_name = ""
	chosen_item_count = 0
	chosen_item_total = 0
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
				inventory_action_chosen.emit(chosen_action, chosen_item_name, 1)
				close()
		"Cancel":
			close_submenu()
			open(_inventory)
		chosen_action:
			inventory_action_chosen.emit(chosen_action, chosen_item_name, 1)
			close()

func _process(_delta):
	if document_selector_open:
		return
	# I have NO IDEA why this needs to be here, but it doesn't work if I remove it
	#if submenu_open:
	#	submenu.grab_focus()
	if not submenu_open and not number_box_open:
		if item_list.is_anything_selected():
			var chosen_index = item_list.get_selected_items().get(0)
			last_selected_item_index = chosen_index
			var _name = inventory_items[chosen_index].name
			var icon = inventory_items[chosen_index].icon
			item_closeup.texture = icon
			name_label.text = "[center]" + _name + "[/center]"
			if Collectible.descriptions.has(_name):
				description_label.text = Collectible.descriptions[_name]
			else:
				description_label.text = "No description available."
	if Input.is_action_just_released("CloseInventory"):
		if number_box_open:
			close_number_box()
			open_submenu()
		elif submenu_open:
			close_submenu()
			open(_inventory)
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
				if chosen_item_name in document_items:
					open_document_selector(_inventory[chosen_item_name])
				else:
					open_submenu()
			return
		elif number_box_open:
			if just_opened:
				just_opened = false
				return
			chosen_item_count = int($Numberbox/RichTextLabel.text)
			if chosen_item_count > 0:
				inventory_action_chosen.emit(chosen_action, chosen_item_name, chosen_item_count)
			close()
