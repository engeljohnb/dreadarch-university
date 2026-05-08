class_name Pot extends Interactable

func activate(using_item : Variant = null, count : int = 1):
	search(using_item, count)
	
func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)

func init():
	var drop_generator = RandomNumberGenerator.new()
	interaction_message = "Z to search"
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
