extends Event
class_name FoundItemEvent

@export var item : Variant = ItemCollection.MAX_TYPES
@export var count : int = 1
@export var dialogue_quote : String

func start():
	if dialogue_quote.is_empty():
		ItemCollection.item_collected.emit(item, count, true)
	else:
		ItemCollection.collect_scroll_fragment(dialogue_quote)
	ItemCollection.show_collected_item(item, null, Vector2(0,-50))
	_finished = true
