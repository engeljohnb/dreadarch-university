extends Control

func on_done():
	get_tree().paused = false
	var collected = []
	for frag in ItemCollection.scroll_fragments:
		if frag["collected"]:
			collected.append(frag)
	Dialogue.dialogue_ended.emit()
	queue_free()

func _ready():
	$TextureRect/Done.pressed.connect(on_done)
	$TextureRect/Done.grab_focus()
	get_tree().paused = true

# Check in _process instead of _ready because when this opens other dialgues
# may be closing at the same time, and when a dialogue closes it usually unpauses
func _process(_delta):
	if not get_tree().paused:
		get_tree().paused = true
