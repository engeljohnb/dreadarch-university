extends ItemList

func _ready():
	mouse_entered.connect(_update_hovered_item)
	#mouse_exited.connect(deselect_all)

func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_update_hovered_item()

func _update_hovered_item():
	var item := get_item_at_position(get_local_mouse_position(), true)
	if item >= 0:
		select(item)
	else:
		deselect_all()
