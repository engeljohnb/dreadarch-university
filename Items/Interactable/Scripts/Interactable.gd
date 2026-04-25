extends StaticBody2D

class_name Interactable

const _my_scene = "res://Items/Interactable/Interactable.tscn"
var interaction_message = "Z to interact"

func activate():
	print("Activated: ", self.name)
	
static func create():
	return load(_my_scene).instantiate()
