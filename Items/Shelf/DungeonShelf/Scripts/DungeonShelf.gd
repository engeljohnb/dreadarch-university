extends Pot

func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)

#func activate(using_item = "", count = 0):
#	if (not using_item.is_empty()) and (count > 0):
#		has_overrides = has
#		has_overrides.append(using_item)
#		amounts.append(count)
#		$Blinker.blink(0.33)
#		ItemCollection.item_collected.emit(using_item, -count, true)
#		activated = false
#		return
#	if (not has_overrides.is_empty()) and not activated:
#		has = has_overrides
#	if not activated:
#		if not has.is_empty():
#			for i in range(0, has.size()):
#				var amount = amounts[i]
#				var h = has[i]
#				match h:
#					ItemCollection.SCROLL_FRAGMENT:
#						if ItemCollection.all_scroll_fragments_collected:
#							has = []
#						else:
#							ItemCollection.sounds[ItemCollection.SCROLL_FRAGMENT].call_deferred("play")
#					h:
#						if Utils.is_scroll_fragment(h):
#							ItemCollection.sounds[ItemCollection.SCROLL_FRAGMENT].call_deferred("play")
#						ItemCollection.item_collected.emit(h, amount, true)
#			activated = true
#			amounts = []
#		else:
#			$ActivateSound.play()
#	else:
#		$ActivateSound.play()
#	$Blinker.blink(0.33)

func _ready():
	can_drop = [ItemCollection.SCROLL_FRAGMENT, ItemCollection.TREASURE]
	has = []
	activated = false
	blink_duration = 0.33
	frame_counter = 0
	has_overrides = []
	amounts = []
	interaction_message = "Z to search"
	var drop_generator = RandomNumberGenerator.new()
	$Blinker.blink_duration = blink_duration
	$Blinker.flip.connect(on_blinker_flipped)
	var odds = drop_generator.randf() 
	if odds > 0.9:
		has.append(can_drop[0])
		amounts.append(1)
	elif odds > 0.25:
		has.append(can_drop[1])
		amounts.append(1)
		
