extends Control


var dialogue = [
		{
			"text":"It's in Latin.",
			"speaker":"Player"
		},
		{
			"text":"I should've paid more attention in class.",
			"speaker":"Player"
		}
]
func on_done():
	get_tree().paused = false
	var collected = []
	for frag in ItemCollection.scroll_fragments:
		if frag["collected"]:
			collected.append(frag)
	#TODO: Change the prompt_player system and the dialogue system and the document viewer until 
	#  this bit of code doesn't need to be in the most random place ever to work.
	if collected.size() == 1:
		if not Tutorial.message_shown(ItemCollection.SCROLL_FRAGMENT):
			Dialogue.open_dialogue.emit(dialogue)
	queue_free()

func _ready():
	$TextureRect/Done.pressed.connect(on_done)
	$TextureRect/Done.grab_focus()
	$TextureRect/RichTextLabel.text = ItemCollection.most_recent_scroll_fragment["latin_text"]
	get_tree().paused = true

# Check in _process instead of _ready because when this opens other dialgues
# may be closing at the same time, and when a dialogue closes it usually unpauses
func _process(_delta):
	if not get_tree().paused:
		get_tree().paused = true
