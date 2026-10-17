extends Control

@warning_ignore("unused_signal")
signal inventory_action_chosen(action, item, count)
signal closed

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("Inventory") and not event.is_echo():
		close()
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			if event.pressed:
				close()
		
func set_button_actions(item : int, button : InventoryItemButton):
	var popup = button.get_popup()
	if ItemCollection.is_drinkable(item):
		popup.add_item("Drink")
	if ItemCollection.is_equippable(item):
		popup.add_item("Equip")
	popup.add_item("Use")
	popup.add_item("Cancel")
	
func on_action_chosen(action : String, item : Variant, count : int):
	inventory_action_chosen.emit(action, item, count)
	
func fill_item_grid(inventory):
	var grid = $TabContainer/Items/GridContainer
	for child in grid.get_children():
		child.queue_free()
	var button_scene = load("res://UI/Inventory/InventoryButton.tscn")
	for key in inventory:
		var item_count = inventory[key]
		if item_count <= 0:
			continue
		var item_id : int = key
		var item_name : StringName = ItemCollection.get_string(item_id)
		var item_icon : Texture2D = ItemCollection.textures[item_id]
		var item_button : InventoryItemButton = button_scene.instantiate()
		
		set_button_actions(item_id, item_button)
		item_button.text = item_name
		item_button.icon = item_icon
		item_button.set_count(item_count)
		item_button.action_chosen.connect(on_action_chosen)
		item_button.close_inventory.connect(close)

		item_button.opened_spinbox.connect(func (): $TabContainer/Items.spinbox_open = true)
		item_button.about_to_popup.connect($TabContainer/Items.close_other_spinboxes.bind(item_button))
		item_button.closed_spinbox.connect(func (): $TabContainer/Items.spinbox_open = false)
		grid.add_child(item_button)

@warning_ignore("unused_parameter")
func open(inventory : Dictionary, documents : Array):
	fill_item_grid(inventory)
	var buttons = $TabContainer/Items/GridContainer.get_children()
	if buttons.size() > 0:
		buttons[0].grab_focus()
		$TabContainer/Items.item_grid_focused.connect(func (): if buttons[0]:
			buttons[0].grab_focus())
		
func set_focus_neighbors(grid: GridContainer):
# Source: https://dredyson.com/why-focus-neighbor-on-identical-nodes-in-a-specific-group-matters-more-than-you-think-an-experts-deep-dive-analysis-of-godot-4-7-gridcontainer-focus-management-with-proven-methods-step-by-step-con/
	var children = grid.get_children()
	var columns = min(children.size(), grid.columns)
	for i in children.size():
		var child = children[i] as Control
		# Left neighbor
		if i % columns != 0:
			child.focus_neighbor_left = children[i-1].get_path()
		# Right neighbor
		if (i+1) % columns != 0:
			child.focus_neighbor_right = children[i+1].get_path()
		# Top neighbor
		if i >= columns:
			child.focus_neighbor_top = children[i-columns].get_path()
		# Bottom neighbor
		if i + columns < children.size():
			child.focus_neighbor_bottom = children[i+columns].get_path()

func close():
	closed.emit()
	queue_free()
