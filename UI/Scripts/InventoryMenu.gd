extends Control
@onready var item_list = $TextureRect/ItemList
var submenu = null
signal inventory_action_chosen(action, item, count)
var submenu_open = false
var number_box_open = false
var chosen_item = ""
var chosen_item_total = 0
var chosen_item_count = 0
var chosen_action = ""
var _inventory : Dictionary
var document_selector_open = false
var document_items = [Collectible.SCROLL_FRAGMENT]
func _ready():
	item_list.item_selected.connect($SelectSound.play)
	get_tree().paused = true
	#submenu.visible = false
	item_list.grab_focus()
	item_list.clear()
	
func open_submenu():
	submenu = load("res://UI/InventorySubmenu.tscn").instantiate()
	item_list.add_child(submenu)
	if chosen_item in Collectible.equippable:
		submenu.add_item("Equip")
	if chosen_item in Collectible.drinkable:
		submenu.add_item("Drink")
	submenu_open = true
	$OpenSound.play()
	submenu.visible = true
	var offset_distance = submenu.offset_top - submenu.offset_bottom
	if item_list.is_anything_selected():
		submenu.offset_top = item_list.get_item_rect(item_list.get_selected_items().get(0)).position.y
		submenu.offset_bottom = submenu.offset_top + offset_distance
	item_list.deselect_all()
	submenu.offset_bottom = submenu.offset_top + offset_distance
	submenu.grab_focus()
	submenu.select(0)
	for index in range(0, item_list.item_count):
		item_list.set_item_disabled(index, true)

func on_document_used(document):
	inventory_action_chosen.emit("Use", document, 1)
	close()
	
func on_document_selector_closed():
	visible = true
	item_list.grab_focus()
	item_list.select(1)
	document_selector_open = false
	
func open_document_selector(documents):
	var doc_sel = load("res://UI/DocumentSelector.tscn").instantiate()	
	add_sibling(doc_sel)
	doc_sel.open(documents)
	doc_sel.closed.connect(on_document_selector_closed)
	doc_sel.document_used.connect(on_document_used)
	visible = false
	document_selector_open = true
	
func open(inventory):
	_inventory = inventory
	for key in inventory:
		if key.is_empty():
			continue
		if (inventory[key] is int) or (inventory[key] is float):
			if inventory[key] > 0:
				item_list.add_item(str(int(inventory[key])), null, false)
				item_list.add_item(key, Collectible.textures[key])
		elif inventory[key] is Array:
			if inventory[key].size() > 0:
				var type = inventory[key][0].get("type")
				if type:
					match type:
						"Scroll Fragment":
							item_list.add_item(str(inventory[key].size()), null, false)
							item_list.add_item(key, Collectible.textures[key])
	item_list.grab_focus()
	item_list.select(1)

func close():
	get_tree().paused = false
	queue_free()

func open_number_box(_max):
	number_box_open = true
	$Numberbox._max = _max
	var offset_distance = $Numberbox.offset_top - $Numberbox.offset_bottom
	if submenu.is_anything_selected():
		$Numberbox.offset_top = submenu.get_item_rect(submenu.get_selected_items().get(0)).position.y
		$Numberbox.offset_bottom = $Numberbox.offset_top + offset_distance
	$Numberbox.visible = true
	submenu.visible = false
	submenu.deselect_all()
	for index in range(0, submenu.item_count):
		submenu.set_item_disabled(index, true)
	
func close_number_box():
	number_box_open = false
	$Numberbox.visible = false
	
func close_submenu():
	chosen_action = ""
	chosen_item = ""
	chosen_item_count = 0
	chosen_item_total = 0
	submenu.queue_free()
	submenu_open = false
	item_list.clear()
		
func _process(_delta):
	if document_selector_open:
		return
	# I have NO IDEA why this needs to be here, but it doesn't work if I remove it
	if submenu_open:
		submenu.grab_focus()
	if Input.is_action_just_pressed("CloseInventory"):
		if number_box_open:
			close_number_box()
			open_submenu()
		elif submenu_open:
			close_submenu()
			open(_inventory)
		else:
			close()
	if Input.is_action_just_pressed("ui_accept"):
		if not submenu_open and not number_box_open:
			if item_list.is_anything_selected():
				chosen_item = item_list.get_item_text(item_list.get_selected_items().get(0))
				chosen_item_total = int(item_list.get_item_text(item_list.get_selected_items().get(0)-1))
				if chosen_item in document_items:
					open_document_selector(_inventory[chosen_item])
				else:
					open_submenu()
		elif submenu_open and not number_box_open:
			if chosen_item_total > 1:
				if submenu.is_anything_selected():
					chosen_action = submenu.get_item_text(submenu.get_selected_items().get(0))
					match chosen_action:
						"Use":
							open_number_box(chosen_item_total)
						chosen_action:
							inventory_action_chosen.emit(chosen_action, chosen_item, 1)
							close()
			else:
				if submenu.is_anything_selected():
					inventory_action_chosen.emit(submenu.get_item_text(submenu.get_selected_items().get(0)), chosen_item, 1)
					close()
		elif number_box_open:
			chosen_item_count = int($Numberbox/RichTextLabel.text)
			if chosen_item_count > 0:
				inventory_action_chosen.emit(chosen_action, chosen_item, chosen_item_count)
			close()
