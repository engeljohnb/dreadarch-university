extends Control

signal action_chosen(action_name)
@onready var container = $VBoxContainer

func on_button_pressed(action_name):
	action_chosen.emit(action_name)
	
func select(_name):
	for child in container.get_children():
		if child.text == _name:
			child.grab_focus()
func clear():
	for child in container.get_children():
		child.queue_free()
		
func add_button(_name):
	var button = Button.new()
	button.text = _name
	button.pressed.connect(on_button_pressed.bind(_name))
	container.add_child(button)
