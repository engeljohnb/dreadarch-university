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

	if event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			$TabContainer.select_next_available()
		elif event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			$TabContainer.select_previous_available()
		
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

func open(inventory : Dictionary):
	fill_item_grid(inventory)
	if $TabContainer.get_tab_bar().current_tab == 0:
		var buttons = $TabContainer/Items/GridContainer.get_children()
		if buttons.size() > 0:
			buttons[0].grab_focus()
			if buttons.size() > 1:
				buttons[0].focus_neighbor_left = buttons[-1].get_path()
				buttons[-1].focus_neighbor_right = buttons[0].get_path()
	$"TabContainer/Scroll Fragments/ScrollFragmentSelector".action_chosen.connect(on_action_chosen)
	var document_item_list_path : NodePath = $"TabContainer/Scroll Fragments/ScrollFragmentSelector/ItemList".get_path()
	var scroll_frag_tab = $"TabContainer/Scroll Fragments"
	scroll_frag_tab.focus_neighbor_bottom = document_item_list_path
	$TabContainer.tab_changed.connect(set_tab_focus_neighbors)
	$"TabContainer/Scroll Fragments/ScrollFragmentSelector".closed.connect(close)
	set_tab_focus_neighbors(0)
	
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

func set_tab_focus_neighbors(_tab):
	var tab_bar = $TabContainer.get_tab_bar()
	var tab_name = $TabContainer.get_current_tab_control().name
	match tab_name:
		"Items":
			var items = $TabContainer/Items/GridContainer.get_children()
			if items.is_empty():
				return
			tab_bar.focus_neighbor_bottom = items[0].get_path()
		"Scroll Fragments":
			var item_list = $"TabContainer/Scroll Fragments/ScrollFragmentSelector/ItemList"
			tab_bar.focus_neighbor_bottom = item_list.get_path()
			item_list.focus_neighbor_top = tab_bar.get_path()
		"Journal":
			return
