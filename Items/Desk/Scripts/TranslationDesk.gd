extends StaticBody2D

var interaction_message = "Z to Translate"
var _trans_menu = load("res://UI/TranslationMenu.tscn")
var canvas = null

func on_closed():
	canvas.queue_free()
	
func activate(_using_item = "", _count = 0):
	var scroll_frags = get_tree().get_nodes_in_group("Player")[0].inventory[Collectible.SCROLL_FRAGMENT]
	var trans_menu = _trans_menu.instantiate()
	canvas = CanvasLayer.new()
	add_child(canvas)
	canvas.add_child(trans_menu)
	trans_menu.open(scroll_frags)
	trans_menu.closed.connect(on_closed)
