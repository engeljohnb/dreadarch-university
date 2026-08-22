extends Interactable

var _trans_menu = preload("res://UI/TranslationMenu.tscn")
var canvas = null

func _ready():
	interaction_message = "Z to translate"
func on_closed():
	# Idk it crashed once.
	if canvas != null:
		canvas.queue_free()
	
func activate(_using_item : Variant = null, _count = 0):
	var scroll_frags = get_tree().get_nodes_in_group("Player")[0].documents
	var trans_menu = _trans_menu.instantiate()
	canvas = CanvasLayer.new()
	add_child(canvas)
	canvas.add_child(trans_menu)
	trans_menu.open(scroll_frags)
	trans_menu.closed.connect(on_closed)
