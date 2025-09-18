extends StaticBody2D

var can_drop = ["", Collectible.HEART, Collectible.SCROLL_FRAGMENT]
var has = ""
var interaction_message = "Z to search"
var showing_item = false
var show_duration = 0.5
var show_timer = 0.0
var item_sprite : Sprite2D
var activated = false
var blink_duration = 0.33
var frame_counter = 0


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
			Collectible.SCROLL_FRAGMENT:
				if Collectible.all_scroll_fragments_collected:
					has = ""
				else:
					showing_item = true
					item_sprite = Sprite2D.new()
					item_sprite.texture = load("res://Assets/Items/ScrollFragment/Scroll.png")
					item_sprite.scale = Vector2(0.5, 0.5)
					sound = $ScrollFragmentSound
					add_child(item_sprite)
		activated = true
	$Blinker.blink(0.33)
	sound.play()

func _ready():
	var drop_generator = RandomNumberGenerator.new()
	$Blinker.blink_duration = blink_duration
	$Blinker.flip.connect(on_blinker_flipped)
	$AnimatedSprite2D.frame = int(abs(global_position.x/3.0)) % 8
	
	var odds = drop_generator.randi() 
	if odds % 12 == 0:
		has = can_drop[2]
	elif odds % 4 == 0:
		has = can_drop[1]
	else:
		has = can_drop[0]
		
func _process(_delta):
	if showing_item:
		show_timer += _delta
		item_sprite.position.y -= _delta*100
		if show_timer >= show_duration:
			if has == Collectible.SCROLL_FRAGMENT:
				Collectible.add_scroll_fragment()
			show_timer = 0.0
			showing_item = false
			item_sprite.queue_free()
			item_sprite = null
