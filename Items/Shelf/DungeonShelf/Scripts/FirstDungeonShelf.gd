extends Pot

var _waiting_for_dialogue := false
var _ui : Variant = null
var _c : int = 0
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

func on_blinker_flipped(state):
	if state:
		modulate = Color(0.5,0.5,0.5)
	else:
		modulate = Color(1,1,1)

func is_first_search():
	return not Tutorial.message_shown(ItemCollection.SCROLL_FRAGMENT)
		
func activate(using_item : Variant = null, count : int = 1):
	var first_search = is_first_search()
	if first_search:
		Dialogue.open_dialogue.emit(search_shelf_dialogue)
		_waiting_for_dialogue = true
		_ui = using_item
		_c = count
	else:
		has.clear()
		search(using_item, count)
		
func _process(_delta):
	if _waiting_for_dialogue:
		if not Dialogue.dialogue_open():
			_waiting_for_dialogue = false
			search(_ui, _c)

func _ready():
	$Blinker.flip.connect(on_blinker_flipped)
	$Blinker.blink_duration = blink_duration
	can_drop = [ItemCollection.SCROLL_FRAGMENT]
	has = [can_drop[0]]
	activated = false
	blink_duration = 0.33
	frame_counter = 0
	has_overrides = []
	amounts = [1]
	interaction_message = "Z to search"
	_waiting_for_dialogue = false
