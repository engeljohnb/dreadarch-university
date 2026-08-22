extends StaticBody2D

class_name Interactable

const _my_scene = "res://Items/Interactable/Interactable.tscn"
var interaction_message = "Z to interact"

var can_drop = [ItemCollection.HEART, ItemCollection.SCROLL_FRAGMENT, ItemCollection.TREASURE]
var has = []
var activated = false
var blink_duration = 0.33
var frame_counter = 0
var player_placed_items = []
var amounts = []

func show_item(item : Variant, index : int = 0):
	var icon_offset = Vector2((32.0 * index) - (32.0*(has.size()-1)/2.0), -32.0)
	if item is Dictionary:
		ItemCollection.show_collected_item(ItemCollection.SCROLL_FRAGMENT, self, icon_offset)
	else:
		ItemCollection.show_collected_item(item, self, icon_offset)
	
func use_item(item: Variant, count : int = 1):
		player_placed_items = has
		player_placed_items.append(item)
		amounts.append(count)
		$Blinker.blink(0.33)
		ItemCollection.item_collected.emit(item, -count, true)
		activated = false
		
func give_scroll_fragment(document_quote):
	if ItemCollection.all_scroll_fragments_collected:
		has = []
	else:
		ItemCollection.sounds[ItemCollection.SCROLL_FRAGMENT].call_deferred("play")
		if not document_quote.is_empty():
			ItemCollection.collect_scroll_fragment(document_quote)
		else:
			ItemCollection.collect_scroll_fragment()
		if not player_placed_items.is_empty():
			# I don't know why this if is here, so I'm putthing a break here until I do
			Error.error("player_placed_items is empty -- you can finally find out what this if statement's for")
			ItemCollection.item_collected.emit(ItemCollection.SCROLL_FRAGMENT, 1, false)
		
func give_all_items(document_quote : String = ""):
	for i in range(0, has.size()):
		var amount = amounts[i]
		var h = has[i]
		show_item(h, has.find(h))
		match h:
			ItemCollection.SCROLL_FRAGMENT:
				give_scroll_fragment(document_quote)
			h:
				if ItemCollection.is_scroll_fragment(h):
					ItemCollection.sounds[ItemCollection.SCROLL_FRAGMENT].call_deferred("play")
				ItemCollection.item_collected.emit(h, amount, true)
				
func search(using_item : Variant = null, count := 1, document_quote := ""):
	if ItemCollection.is_valid_item(using_item):
		use_item(using_item, count)
		return
	if (not player_placed_items.is_empty()) and not activated:
		has = player_placed_items
	if not activated:
		if not has.is_empty():
			give_all_items(document_quote)
			activated = true
			amounts = []
			has = []
		else:
			$ActivateSound.play()
	else:
		$ActivateSound.play()
	$Blinker.blink(0.33)
	
func init():
	pass
func _ready():
	init()
	
func activate(_using_item : Variant = null, _count = 1):
	pass
	
static func create():
	return load(_my_scene).instantiate()
