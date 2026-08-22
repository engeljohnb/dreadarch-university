#TODO: New icons for everything from scatch to resolve inconsistent sizes.

extends Node
# Handles the parts of item collection that are shared by many systems (UI, inventory, Interactable).
#  This is distinct from the Collectible class, which only handles the game objects on the ground 
#  the player can pick up.

@warning_ignore("unused_signal")
signal item_collected(item : Variant, count : int, should_play_sound : bool)
@warning_ignore("unused_signal")
signal scroll_fragment_translated(scroll_fragment)

#Why double up the enum? Because sometimes I want to just do ItemCollection.TALONS for brevity,
#  but other times I want to set it as a type 
#   @export var item_type : ItemCollection.IDs
enum
{
	HEART = 0,
	SCROLL_FRAGMENT,
	TREASURE,
	TALONS,
	GOLDEN_DAGGER,
	NECTAR,
	ORBITER,
	MAX_TYPES
}

enum IDs
{
	HEART = 0,
	SCROLL_FRAGMENT,
	TREASURE,
	TALONS,
	GOLDEN_DAGGER,
	NECTAR,
	ORBITER,
	MAX_TYPES
}

var item_reveal = preload("res://Items/Collectible/ItemReveal.tscn")

var equippable : Array[int] = [TALONS, GOLDEN_DAGGER, ORBITER]

var drinkable = [NECTAR]

var textures = {
	HEART:preload("res://Assets/Items/Heart/0000.png"),
	SCROLL_FRAGMENT:preload("res://Assets/Items/ScrollFragment/Scroll.png"),
	TREASURE:preload("res://Assets/Items/Treasure/0000.png"),
	TALONS:preload("res://Assets/Badguys/Crow/Attack/Projectile/Down/0000.png"),
	GOLDEN_DAGGER:preload("res://Assets/Items/GoldenDagger/0000.png"),
	NECTAR:preload("res://Assets/Items/Nectar/0000.png"),
	ORBITER:preload("res://Assets/Badguys/Slack/Projectile/0000.png")
}

var streams = {
	HEART:preload("res://Assets/Sounds/Heart/CollectSound.ogg"),
	SCROLL_FRAGMENT:preload("res://Assets/Sounds/OpenMenu.mp3"),
	TREASURE:preload("res://Assets/Sounds/Items/TreasureCollectedSound.ogg"),
	TALONS:preload("res://Assets/Sounds/Items/TalonCollectedSound.ogg"),
	GOLDEN_DAGGER:preload("res://Assets/Sounds/Items/SwordCollectedSound.ogg"),
	NECTAR:preload("res://Assets/Sounds/Heart/CollectSound.ogg"),
	ORBITER:preload("res://Assets/Sounds/EnemyDeath.ogg")
}

var spriteframes = {
	HEART:preload("res://Items/Heart/Heart.tres"),
	SCROLL_FRAGMENT:null,
	TREASURE:preload("res://Items/Treasure/Treasure.tres"),
	TALONS:preload("res://Weapons/Projectiles/Talons/CrowProjectileSpriteframes.tres"),
	GOLDEN_DAGGER:preload("res://Items/GoldenDagger/GoldenDagger.tres"),
	ORBITER:preload("res://Items/Orbiter/orbiter_spriteframes.tres")
}

var descriptions = {
	TREASURE : "Not standard currency anymore, but may still be valuable.",
	TALONS : "Claws from those cursed crows. Throwing them could be hazardous.",
	GOLDEN_DAGGER : "The creatures in the ruins seem to be afraid of it.",
	NECTAR : "Very refreshing.",
	SCROLL_FRAGMENT : "Scraps of writing I found in the ruins.",
	ORBITER : "Looks like a cute little ghost. Hurts when one flies into you."
}
					
var sounds = {}
var scroll_fragments : Array[Dictionary]
var most_recent_scroll_fragment : Dictionary
var all_scroll_fragments_collected = false
var fragments_to_level_up = 5

func is_scroll_fragment(document):
	if not (document is Dictionary):
		return false
	return document.get("document_type") == ItemCollection.SCROLL_FRAGMENT

func is_document(document):
	return document is Dictionary
	
# Why isn't this stuff implemented in Collectible? Because I made 
#  this first and it still works. 
	
func get_string(item : int):
	match item:
		HEART: return "Heart"
		SCROLL_FRAGMENT: return "Scroll Fragment"
		TREASURE: return "Treasure"
		TALONS: return "Talons"
		GOLDEN_DAGGER: return "Golden Dagger"
		NECTAR: return "Nectar"
		ORBITER: return "Little Sprite"
		item: return "Invalid Item ID"
		
func is_item_id_valid(item : int):
	return (item >= 0) and (item < MAX_TYPES)
	
func on_item_collected(item, _count, should_play_sound):
	if sounds.get(item):
		if should_play_sound:
			sounds[item].call_deferred("play")
	elif item is Dictionary:
		sounds[SCROLL_FRAGMENT].call_deferred("play")
	if (_count < 1):
		return
	if Tutorial.has_message(item):
		if not Tutorial.message_shown(item):
			Tutorial.show_message(item)

func is_valid_special_item(item : Variant) -> bool:
	if item is Dictionary:
		return true
	return false
	
func is_valid_counted_item(item : Variant) -> bool:
	if item is int:
		return is_item_id_valid(item)
	else:
		return false
func is_valid_item(item: Variant) -> bool:
	var valid = (is_valid_special_item(item) or is_valid_counted_item(item))
	return valid
	
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
	var sf = DictionarySerializer.deserialize_json(file.get_as_text())
	for scroll_fragment in sf:
		scroll_fragments.append(scroll_fragment)
	for frag in scroll_fragments:
		frag["document_type"] = SCROLL_FRAGMENT
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
	Tutorial.messages_shown[ItemCollection.SCROLL_FRAGMENT] = false
	
func disable_scroll_fragment_tutorial():
	Tutorial.messages_shown[ItemCollection.SCROLL_FRAGMENT] = true
	
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
	
func is_quote_in_scroll_fragment(scroll_fragment : Dictionary, document_quote : String) -> bool:
	for key in scroll_fragment:
		if scroll_fragment[key] is String:
			if scroll_fragment[key].containsn(document_quote):
				return true
	return false
		
func search_for_scroll_fragment(document_quote : String) -> Dictionary:
	for scroll_fragment in scroll_fragments:
		if is_quote_in_scroll_fragment(scroll_fragment, document_quote):
			return scroll_fragment
	return {}
	
func collect_scroll_fragment(index = null):
	if index is String:
		var document_quote : String = index
		var scroll_fragment : Dictionary = search_for_scroll_fragment(document_quote)
		if scroll_fragment.is_empty():
			Error.error("No scroll fragment contains quote: '" + document_quote + "'")
		most_recent_scroll_fragment = scroll_fragment
		item_collected.emit(scroll_fragment, 1, true)
		return
	if index is int:
		most_recent_scroll_fragment = get_next_fragment(index)
	else:
		most_recent_scroll_fragment = get_next_fragment()
	item_collected.emit(most_recent_scroll_fragment, 1, true)

func show_collected_item(item: int, collector : Variant = null, offset : Vector2 = Vector2()):
	# The item icon will follow the collector. If not specified, defaults to player.
	var node : ItemReveal = item_reveal.instantiate()
	node.transform_into(item)
	if collector == null:
		collector = get_tree().get_nodes_in_group("Player")[0]
	collector.add_child(node)
	node.show_item(offset)

	
