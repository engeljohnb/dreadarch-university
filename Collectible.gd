extends Node

@warning_ignore("unused_signal")
signal item_collected(item, count, should_play_sound)
@warning_ignore("unused_signal")
signal scroll_fragment_translated(scroll_fragment)
const HEART = "Heart"
const SCROLL_FRAGMENT = "Scroll Fragment"
const TREASURE = "Treasure"
const TALONS = "Talons"
const GOLDEN_DAGGER = "Golden Dagger"
const NECTAR = "Nectar"

var equippable = [TALONS, GOLDEN_DAGGER]

var drinkable = [NECTAR]

var collected_first = {
	TALONS:false,
	NECTAR:false
}
var textures = {
	HEART:load("res://Assets/Items/Heart/0000.png"),
	SCROLL_FRAGMENT:load("res://Assets/Items/ScrollFragment/Scroll.png"),
	TREASURE:load("res://Assets/Items/Treasure/0000.png"),
	TALONS:load("res://Assets/Badguys/Crow/Attack/Projectile/Down/0000.png"),
	GOLDEN_DAGGER:load("res://Assets/Items/GoldenDagger/0000.png"),
	NECTAR:load("res://Assets/Items/Nectar/0000.png")
	
				}

var projectiles = {
	TALONS:load("res://Characters/Crow/Projectile/CrowProjectile.tscn")
}

var streams = {
	HEART:load("res://Assets/Sounds/Heart/CollectSound.ogg"),
	SCROLL_FRAGMENT:load("res://Assets/Sounds/OpenMenu.mp3"),
	TREASURE:load("res://Assets/Sounds/Items/TreasureCollectedSound.ogg"),
	TALONS:load("res://Assets/Sounds/Items/TalonCollectedSound.ogg"),
	GOLDEN_DAGGER:load("res://Assets/Sounds/Items/SwordCollectedSound.ogg"),
	NECTAR:load("res://Assets/Sounds/Heart/CollectSound.ogg")
}

var spriteframes = {
	HEART:load("res://Items/Heart/Heart.tres"),
	SCROLL_FRAGMENT:null,
	TREASURE:load("res://Items/Treasure/Treasure.tres"),
	TALONS:load("res://Characters/Crow/Projectile/CrowProjectileSpriteframes.tres"),
	GOLDEN_DAGGER:load("res://Items/GoldenDagger/GoldenDagger.tres"),
	NECTAR:null
}

var tutorial_notes = {
	TALONS:[
		{
			"text":"You found talons! ",
			"image":textures[TALONS],
			"text2":" You can use these as a weapon."
		},
		{
			"text":"To equip them, press I to open your inventory, or use the shift keys to change your equipped item."
		}
	],
	NECTAR:[
		{
			"text":"You found nectar! ",
			"image":textures[NECTAR],
			"text2":" Drinking these is good for your health. You can press I to open your inventory."
		}
	]
}

var sounds = {}
var scroll_fragments : Array
var most_recent_scroll_fragment : Dictionary
var all_scroll_fragments_collected = false
var fragments_to_level_up = 5

func load_completed_tutorial_prompts(completed):
	for c in completed:
		collected_first[c] = true
	
func get_completed_tutorial_prompts():
	var completed = []
	for key in collected_first:
		if collected_first[key]:
			completed.append(key)
	return completed
	
func on_item_collected(item, _count, should_play_sound):
	if sounds.get(item):
		if should_play_sound:
			sounds[item].call_deferred("play")
	if (_count < 1):
		return
	if collected_first.get(item) != null:
		if (collected_first[item] == false):
			Dialogue.notify_player.emit(tutorial_notes[item])
			collected_first[item] = true
		
func _ready():
	for key in streams:
		sounds[key] = AudioStreamPlayer.new()
		sounds[key].stream = streams[key]
		match key:
			TREASURE:
				sounds[key].volume_db = -20.0
			TALONS:
				sounds[key].volume_db = -20.0
			HEART:
				sounds[key].volume_db = -20.0
			NECTAR:
				sounds[key].volume_db = -20.0
			GOLDEN_DAGGER:
				sounds[key].volume_db = -20.0
		add_child(sounds[key])
	var file = FileAccess.open("res://Game Data/scroll_fragments.JSON", FileAccess.READ)
	scroll_fragments = DictionarySerializer.deserialize_json(file.get_as_text())
	file.close()

func load_collected_scroll_fragments(collected : Array):
	for frag in scroll_fragments:
		for c in collected:
			if frag["latin_text"] == c["latin_text"]:
				frag["collected"] = true
	if collected.size() == scroll_fragments.size():
		all_scroll_fragments_collected = true
		
func on_scroll_frag_yes():
	Dialogue.open_document.emit()
	
func on_scroll_frag_no():
	pass
	
func prompt_to_read_scroll_fragment():
	Dialogue.prompt_player.emit("You found a scroll fragment! Read it?", on_scroll_frag_yes, on_scroll_frag_no, "yes", "no")

func get_next_fragment(index = null):
	if index is int:
		return scroll_fragments[index]
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
	
func collect_scroll_fragment(index = null):
	prompt_to_read_scroll_fragment()
	if index is int:
		most_recent_scroll_fragment = get_next_fragment(index)
	else:
		most_recent_scroll_fragment = get_next_fragment()
	item_collected.emit(most_recent_scroll_fragment, 1, true)
