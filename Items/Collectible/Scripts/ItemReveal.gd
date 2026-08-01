extends Node2D
class_name ItemReveal

var start_position : Vector2
var timer : float = 0.0
var _showing : bool = false

func transform_into(type : int) -> Node2D:
	z_index = 1
	var sprite : Sprite2D = Sprite2D.new()
	sprite.texture = ItemCollection.textures.get(type)
	if sprite.texture == null:
		push_warning("item has no texture.")
		return self
	add_child(sprite)
	return self

func show_item(_position : Vector2 = Vector2()):
	start_position = _position
	position = _position
	_showing = true
	timer = 0.0
	
func _process(_delta):
	if _showing:
		var duration = 0.66
		var pa = 0.2
		var padink = Utils.padink(timer, duration, pa) * 15.0
		position.y = start_position.y - padink
		timer += _delta
		if timer >= duration:
			queue_free()
