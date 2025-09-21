extends Control
@onready var item_list = $TextureRect/ItemList
@onready var submenu = $TextureRect/ItemList/Submenu
signal inventory_action_chosen(action, item, count)
var submenu_open = false
var number_box_open = false
var chosen_item = ""
var chosen_item_total = 0
var chosen_item_count = 0
var chosen_action = ""
var equippable = [Collectible.TALONS, Collectible.GOLDEN_DAGGER]

func _ready():
	get_tree().paused = true
	submenu.visible = false
	item_list.grab_focus()
	item_list.clear()
	
func open_submenu():
	if chosen_item in equippable:
		submenu.add_item("Equip")
	submenu_open = true
	$OpenSound.play()
	submenu.visible = true
	var offset_distance = submenu.offset_top - submenu.offset_bottom
	if item_list.is_anything_selected():
		submenu.offset_top = item_list.get_item_rect(item_list.get_selected_items().get(0)).position.y
		submenu.offset_bottom = submenu.offset_top + offset_distance
	submenu.grab_focus()
	submenu.select(0)
	item_list.deselect_all()
	for index in range(0, item_list.item_count):
		item_list.set_item_disabled(index, true)

func open(inventory):
	for key in inventory:
		if key.is_empty():
			return
		if (inventory[key] is int) or (inventory[key] is float):
			if inventory[key] > 0:
				item_list.add_item(str(int(inventory[key])), null, false)
				item_list.add_item(key, Collectible.textures[key])
	item_list.grab_focus()
	item_list.select(1)
	item_list.item_selected.connect($SelectSound.play)

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
	
func _process(_delta):
	if Input.is_action_just_pressed("CloseInventory"):
		close()
	if Input.is_action_just_released("ui_accept"):
		if not submenu_open and not number_box_open:
			if item_list.is_anything_selected():
				chosen_item = item_list.get_item_text(item_list.get_selected_items().get(0))
				chosen_item_total = int(item_list.get_item_text(item_list.get_selected_items().get(0)-1))
				open_submenu()
		elif submenu_open and not number_box_open:
			if chosen_item_total > 1:
				if submenu.is_anything_selected():
					chosen_action = submenu.get_item_text(submenu.get_selected_items().get(0))
					match chosen_action:
						"Use":
							open_number_box(chosen_item_total)
						"Equip":
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
