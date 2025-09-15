extends StaticBody2D

var can_drop = ["", Collectible.HEART]
var has = ""
var interaction_message = "Z to search"
var showing_item = false
var show_duration = 0.5
var show_timer = 0.0
var item_sprite : Sprite2D
var activated = false
var blink_duration = 0.33

func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)
	
func activate():
	var sound = $ActivateSound
	if not activated:
		match has:
			Collectible.HEART:
				showing_item = true
				item_sprite = Sprite2D.new()
				item_sprite.texture = load("res://Assets/Items/Heart/0000.png")
				add_child(item_sprite)
				sound = $HeartSound
				get_tree().get_nodes_in_group("Player")[0].gain_life(1)
		activated = true
	$Blinker.blink(0.33)
	sound.play()

func _ready():
	var frame_generator = RandomNumberGenerator.new()
	var drop_generator = RandomNumberGenerator.new()
	$Blinker.blink_duration = blink_duration
	$Blinker.flip.connect(on_blinker_flipped)
	frame_generator.randomize()
	drop_generator.randomize()
	$AnimatedSprite2D.frame = frame_generator.randi_range(0,7)
	
	var chances = drop_generator.randi_range(0,3)
	if chances == 0:
		has = can_drop[1]
	else:
		has = can_drop[0]
		
func _process(_delta):
	if showing_item:
		show_timer += _delta
		item_sprite.position.y -= _delta*100
		if show_timer >= show_duration:
			show_timer = 0.0
			showing_item = false
			item_sprite.queue_free()
			item_sprite = null
