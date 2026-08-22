extends Node
class_name EventSequence

var _started := false

class Event:
	extends Node
	var _finished : bool = false
	@warning_ignore("unused_private_class_variable")
	var _started := false
	func _set_finished(state : bool):
		_finished = state
	func is_finished() -> bool:
		return _finished
	func start():
		pass
	func end():
		queue_free()
	func _process(delta : float) -> void:
		pass
		
class NotificationEvent:
	extends Event
	var tutorial_key : int = ItemCollection.IDs.MAX_TYPES
	var message : Array
	func start():
		Dialogue.dialogue_ended.connect(_set_finished.bind(true))
		if message.is_empty():
			if tutorial_key == ItemCollection.IDs.MAX_TYPES:
				Error.error("No message defined for NotificationEvent")
			else:
				Tutorial.show_message(tutorial_key)
		else:
			Dialogue.notify_player.emit(message)
	
class DialogueEvent:
	extends Event
	var dialogue : Array
	func start():
		Dialogue.dialogue_ended.connect(_set_finished.bind(true))
		Dialogue.open_dialogue.emit(dialogue)

class FoundItemEvent:
	extends Event
	var item : Variant = ItemCollection.MAX_TYPES
	var count : int = 1
	var dialogue_quote : String
	func start():
		if dialogue_quote.is_empty():
			ItemCollection.item_collected.emit(item, count, true)
		else:
			ItemCollection.collect_scroll_fragment(dialogue_quote)
		ItemCollection.show_collected_item(item, null, Vector2(0,-50))
		_finished = true

var queue : Array[Event] = []

func _process(_delta):
	if _started:
		if queue.is_empty():
			queue_free()
			return
		var event = queue[0]
		if not event._started:
			event.start()
			# Shouldn't this be implemented in Event? Maybe, but start()
			#  is implemented by only by subclasses, and I want to avoid having
			#  a chore for each subclass to have to remember.
			event._started = true
		else:
			if event.is_finished():
				queue.erase(event)
				event.end()
			else:
				# The events aren't children, so they're not in the scene tree,
				#   so process has to be called manually. 
				event._process(_delta)

func add_event(event : Event):
	queue.append(event)

func add_dialogue_event(dialogue : Array):
	var event = DialogueEvent.new()
	event.dialogue = dialogue
	add_event(event)
	
func add_notification_event(message : Array = [], tutorial_key : int = ItemCollection.IDs.MAX_TYPES):
	var event = NotificationEvent.new()
	event.message = message
	event.tutorial_key = tutorial_key
	add_event(event)
	
func add_found_item_event(item : Variant, count : int = 1):
	var event = FoundItemEvent.new()
	event.item = item
	event.count = count
	add_event(event)

func start_events():
	_started = true
