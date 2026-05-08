extends Pot

func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)

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
		
