extends StaticBody2D

var can_drop = [Collectible.HEART, Collectible.SCROLL_FRAGMENT, Collectible.TREASURE]
var has = []
var interaction_message = "Z to search"
var showing_item = false
var show_duration = 0.5
var show_timer = 0.0
var item_sprites : Array[Sprite2D]
var activated = false
var blink_duration = 0.33
var frame_counter = 0
var has_overrides = []
var amounts = []
var type = Types.POT

func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)

	
func activate(using_item = "", count = 0):
	if (not using_item.is_empty()) and (count > 0):
		has_overrides = has
		has_overrides.append(using_item)
		amounts.append(count)
		$Blinker.blink(0.33)
		Collectible.item_collected.emit(using_item, -count)
		activated = false
		return
	if (not has_overrides.is_empty()) and not activated:
		has = has_overrides
	if not activated:
		if not has.is_empty():
			for i in range(0, has.size()):
				var amount = amounts[i]
				var h = has[i]
				var item_sprite = Sprite2D.new()
				if (Collectible.textures.get(h)):
					item_sprite.texture = Collectible.textures[h]
				add_child(item_sprite)
				showing_item = true
				item_sprites.append(item_sprite)
				match h:
					Collectible.SCROLL_FRAGMENT:
						if Collectible.all_scroll_fragments_collected:
							item_sprite.queue_free()
							has = []
						else:
							Collectible.sounds[Collectible.SCROLL_FRAGMENT].call_deferred("play")
					h:
						Collectible.item_collected.emit(h, amount)
			activated = true
			amounts = []
		else:
			$ActivateSound.play()
	else:
		$ActivateSound.play()
	$Blinker.blink(0.33)

func _ready():
	var drop_generator = RandomNumberGenerator.new()
	$Blinker.blink_duration = blink_duration
	$Blinker.flip.connect(on_blinker_flipped)
	$AnimatedSprite2D.frame = int(abs(global_position.x/3.0)) % 8
	
	var odds = drop_generator.randf() 
	if odds > 0.9:
		has.append(can_drop[1])
		amounts.append(1)
	elif odds > 0.66:
		has.append(can_drop[0])
		amounts.append(1)
	elif odds > 0.33:
		has.append(can_drop[2])
		amounts.append(1)
		
func _process(_delta):
	if showing_item:
		show_timer += _delta
		for i in range(0, item_sprites.size()):
			var item_sprite = item_sprites[i]
			item_sprite.position.y -= _delta*100
			item_sprites[i].position.x = i*32 - ((item_sprites.size()-1) * 16)
		if show_timer >= show_duration:
			if Collectible.SCROLL_FRAGMENT in has:
				# Doing this here instead of emitting Collectible.item_collected
				# so the sound plays immediately but the prompt to read
				# only opens after the scroll icon finishes its animation
				Collectible.collect_scroll_fragment()
			show_timer = 0.0
			showing_item = false
			for item_sprite in item_sprites:
				item_sprite.queue_free()
			item_sprites = []
			has = []
