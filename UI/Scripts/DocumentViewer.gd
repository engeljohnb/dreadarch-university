extends Control

var dialogue = [
	{
		"text":"It's in the Old Tongue.",
		"speaker":"Player"
	},
	{
		"text":"I should've paid more attention in class.",
		"speaker":"Player"
	}
]

var level_up_dialogue = [
	{
		"text":"I should take these back up to the library. I bet I could translate it if I had some dictionaries.",
		"speaker":"Player"
	}
]
func on_done():
	get_tree().paused = false
	var collected = []
	for frag in Collectible.scroll_fragments:
		if frag["collected"]:
			collected.append(frag)
	if collected.size() == 1:
		Dialogue.open_dialogue.emit(dialogue)
	if collected.size() == Collectible.fragments_to_level_up:
		Dialogue.open_dialogue.emit(level_up_dialogue)
	queue_free()

func _ready():
	$TextureRect/Done.pressed.connect(on_done)
	$TextureRect/Done.grab_focus()
	$TextureRect/RichTextLabel.text = Collectible.most_recent_scroll_fragment["latin_text"]
	get_tree().paused = true

# Check in _process instead of _ready because when this opens other dialgues
# may be closing at the same time, and when a dialogue closes it usually unpauses
func _process(_delta):
	if not get_tree().paused:
		get_tree().paused = true
