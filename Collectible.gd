extends Node

signal scroll_fragment_collected()
const HEART = "Heart"
const SCROLL_FRAGMENT = "Scroll Fragment"

var scroll_fragments : Array
var most_recent_scroll_fragment : Dictionary
var all_scroll_fragments_collected = false

func _ready():
	var file = FileAccess.open("res://Game Data/scroll_fragments.JSON", FileAccess.READ)
	scroll_fragments = DictionarySerializer.deserialize_json(file.get_as_text())

func load_collected_scroll_fragments(collected):
	for frag in scroll_fragments:
		for c in collected:
			if frag.recursive_equal(c, 1):
				frag["collected"] = true
	if collected.size() == scroll_fragments.size():
		all_scroll_fragments_collected = true
		
func on_scroll_frag_yes():
	Dialogue.open_document.emit()
	
func on_scroll_frag_no():
	pass
	
func prompt_to_read_scroll_fragment():
	Dialogue.prompt_player.emit("You found a scroll fragment! Read it?", on_scroll_frag_yes, on_scroll_frag_no, "yes", "no")

func get_next_fragment():
	var uncollected = []
	var frag_gen = RandomNumberGenerator.new()
	for fragment in scroll_fragments:
		if not fragment["collected"]:
			uncollected.append(fragment)
	if uncollected.size() == 1:
		all_scroll_fragments_collected = true
	var fragment = uncollected[frag_gen.randi_range(0, uncollected.size()-1)]
	for f in scroll_fragments:
		if f == fragment:
			f["collected"] = true
	return fragment
	
func add_scroll_fragment():
	prompt_to_read_scroll_fragment()
	most_recent_scroll_fragment = get_next_fragment()
	scroll_fragment_collected.emit()
