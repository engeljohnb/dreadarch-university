extends Pot

var _waiting_for_dialogue := false
var search_shelf_dialogue = [
	{
		"text":"Looks like the military picked it clean.",
		"speaker":"Player"
	},
	{
		"text":"Hey, wait... Seems they didn't get everything.",
		"speaker":"Player"
	}
]
var found_scroll_dialogue = [
	{
			"text":"It's in Latin.",
			"speaker":"Player"
		},
		{
			"text":"I should've paid more attention in class.",
			"speaker":"Player"
		}
]


func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)

func is_first_search():
	return not Tutorial.message_shown(ItemCollection.SCROLL_FRAGMENT)
		
func _remove_events(seq : EventSequence, events : Array):
	for event in events:
		seq.remove_event(event)
		
func _launch_event_sequence():
	var seq : EventSequence = EventSequence.new()
	var prompt = "You found a scroll fragment! Do you want to read it?"
	var on_yes = func(): pass
	var on_no = func(): pass
	
	seq.add_dialogue_event(search_shelf_dialogue)
	var prompt_event = seq.add_prompt_event(prompt, on_yes, on_no)
	seq.add_found_item_event(ItemCollection.SCROLL_FRAGMENT, 1, "Aelia...")
	var dialogue_event = seq.add_dialogue_event(found_scroll_dialogue)
	
	prompt_event.on_no = _remove_events.bind(seq, [prompt_event, dialogue_event])
	
	add_child(seq)
	seq.start_events()
	
func activate(using_item : Variant = null, count : int = 1):
	var first_search = is_first_search()
	if first_search:
		_launch_event_sequence()
		Tutorial.messages_shown[ItemCollection.SCROLL_FRAGMENT] = true
	else:
		has.clear()
		search(using_item, count)
		

func _ready():
	$Blinker.flip.connect(on_blinker_flipped)
	$Blinker.blink_duration = blink_duration
	can_drop = [ItemCollection.SCROLL_FRAGMENT]
	has = [can_drop[0]]
	activated = false
	blink_duration = 0.33
	frame_counter = 0
	player_placed_items = []
	amounts = [1]
	_waiting_for_dialogue = false
