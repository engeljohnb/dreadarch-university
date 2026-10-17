extends Control

@onready var grid = $GridContainer
@onready var info = $Info
signal item_grid_focused

var spinbox_open = false

func close_other_spinboxes(target_button : InventoryItemButton):
	for child : InventoryItemButton in grid.get_children():
		if child != target_button:
			child.hide_spinbox(false)

func _process(_delta):
	if spinbox_open:
		return
	var found_display = false
	for child : Button in grid.get_children():
		if child.is_hovered():
			display_info(child)
			found_display = true
			break
	if not found_display:
		for child : Button in grid.get_children():
			if child.has_focus():
				display_info(child)
				found_display = true
				break
	if not found_display:
		display_blank()

func display_blank():
	$Info/Image.texture = null
	$Info/Description.text = ""
	$Info/ItemName.text = ""
	
func display_info(button : Button):
	var item_name = button.text
	var id : int = ItemCollection.get_id(item_name)
	$Info/Image.texture = ItemCollection.textures[id]
	$Info/Description.text = ItemCollection.descriptions[id]
	$Info/ItemName.text = item_name

func _input(event : InputEvent):
	# This is the only way I can figure out to make it so the first button in the
	#  inventory grid is focused when the focus exits from the TabContainer.
	#  Everything else I try, Godot just ignores the focus neighbors and focuses
	#  the last button in the grid.
	if event.is_action_pressed("ui_down"):
		if get_parent().get_tab_bar().has_focus():
			item_grid_focused.emit()
