extends TabContainer

func _ready():
	tab_selected.connect(update_all_buttons)
	
func update_all_buttons(tab : int):
	if get_tab_title(tab) == "Customize":
		var customize_tab = get_tab_control(tab)
		for child in customize_tab.get_children():
			if (child is RemapButton) or (child is MotionRemapButton):
				child.update_button_text()
