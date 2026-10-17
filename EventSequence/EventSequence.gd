extends Node
class_name EventSequence

signal ended

var free_on_finish = true
var _started := false
		
var queue : Array[Event] = []

func stop():
	ended.emit()
	if free_on_finish:
		queue_free()
		_started = false
		
func _process(_delta):
	if _started:
		if queue.is_empty():
			stop()
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
				if not event.is_inside_tree(): 
					event._process(_delta)

func add_event(event : Event) -> Event:
	queue.append(event)
	return event

func add_dialogue_event(dialogue : Array) -> DialogueEvent:
	var event = DialogueEvent.new()
	event.dialogue = dialogue
	add_event(event)
	return event
	
func add_notification_event(message : Array = [], tutorial_key : Variant = ItemCollection.IDs.MAX_TYPES) -> NotificationEvent:
	var event = NotificationEvent.new()
	event.message = message
	event.tutorial_key = tutorial_key
	add_event(event)
	return event
	
func add_found_item_event(item : Variant, count : int = 1, dialogue_quote : String = "") -> FoundItemEvent:
	var event = FoundItemEvent.new()
	event.dialogue_quote = dialogue_quote
	event.item = item
	event.count = count
	add_event(event)
	return event

func add_prompt_event(message : String, on_yes : Callable, on_no : Callable, yes_text := "Yes", no_text := "No") -> PromptEvent:
	var event = PromptEvent.new()
	event.message = message
	event.on_yes = on_yes
	event.on_no = on_no
	event.yes_text = yes_text
	event.no_text = no_text
	add_event(event)
	return event
	
func add_view_document_event() -> ViewDocumentEvent:
	var event := ViewDocumentEvent.new()
	add_event(event)
	return event
	
func add_cutscene_event(cutscene : StringName, target : Variant = "Player", one_time : bool = false) -> CutsceneEvent:
	var event : CutsceneEvent = CutsceneEvent.new()
	event.cutscene = cutscene
	event.target = target
	event.one_time = one_time
	add_event(event)
	# Cutscene events need to be in the tree to work
	add_child(event)
	return event
	
func add_walk_event(target_position : Vector2, duration : float) -> WalkEvent:
	var event : WalkEvent = WalkEvent.new()
	event.target_position = target_position
	event.duration = duration
	add_event(event)
	add_child(event)
	return event
	
func start_events():
	_started = true

func remove_event(event : Event):
	queue.erase(event)
	event.queue_free()
