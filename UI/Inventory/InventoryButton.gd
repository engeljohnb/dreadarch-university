extends MenuButton
class_name InventoryItemButton

signal action_chosen(action, item, count)
signal close_inventory
signal opened_spinbox
signal closed_spinbox
var action_name : String = ""
var item_id : int = -1

var _text = ""
var _total = 0
var _icon : Texture2D = null

func _ready():
	$SpinBox.focus_mode = FOCUS_NONE
	$SpinBox/Accept.focus_mode = FOCUS_NONE
	$SpinBox/Cancel.focus_mode = FOCUS_NONE
	$SpinBox/Accept.pressed.connect(on_accepted)
	$SpinBox/Cancel.pressed.connect(on_canceled)
	_text = text
	_icon = icon
	get_popup().index_pressed.connect(on_pressed)
	
func set_count(total : int):
	$Count.text = str(total)
	_total = total
	$SpinBox.max_value = total
	
func on_pressed(index : int):
	var popup = get_popup()
	action_name = popup.get_item_text(index)
	item_id = ItemCollection.get_id(text)
	var total = int($Count.text)
	if action_name == "Cancel":
		return
	if (total == 1) or (action_name != "Use"):
		action_chosen.emit(action_name, item_id, 1)
		close_inventory.emit()
	else:
		show_spinbox()
		
func on_accepted():
	var count = int($SpinBox.value)
	action_chosen.emit(action_name, item_id, count)
	close_inventory.emit()
	
func on_canceled():
	hide_spinbox()
	
func show_spinbox():
	opened_spinbox.emit()
	$SpinBox.enable()
	text = ""
	$Count.text = ""
	icon = null
	$SpinBox.grab_focus()

func hide_spinbox(should_emit = true):
	if should_emit:
		closed_spinbox.emit()
	$SpinBox.disable()
	text = _text
	$Count.text = str(_total)
	icon = _icon
