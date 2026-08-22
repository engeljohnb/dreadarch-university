extends Pot

func activate(using_item = null, count = 0):
	if using_item:
		search(using_item, count)
	else:
		var seq = EventSequence.new()
		var note = [{"text"  : "This is a test of the emergency broadcasting system."}]
		var item = ItemCollection.TREASURE
		var c = 10
		var dialogue = [{"speaker" : "Player",
						  "text" : "The test is completed."}]
		
		seq.add_notification_event(note)
		seq.add_found_item_event(item, c)
		seq.add_dialogue_event(dialogue)
		add_child(seq)
		seq.start_events()
