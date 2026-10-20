extends TabContainer

func _ready():
	tab_selected.connect(update_all_buttons)
	
func update_all_buttons(tab : int):
	if get_tab_title(tab) == "Customize":
		var customize_tab = get_tab_control(tab)
		for child in customize_tab.get_children():
			if (child is RemapButton) or (child is MotionRemapButton):
				child.update_button_text()

func set_focus_neighbors(tab):
	var tab_bar : TabBar = get_tab_bar()
	match tab:
		0:
			var motion_button = $Customize/MotionButton
			tab_bar.focus_neighbor_bottom = motion_button.get_path()
		1:
			var item_list = $Presets/ItemList
			tab_bar.focus_neighbor_bottom = item_list.get_path()
