extends Node

var messages_shown = {
		ItemCollection.TALONS : false,
		ItemCollection.NECTAR : false,
		ItemCollection.SCROLL_FRAGMENT : false
}
var messages = {
	ItemCollection.TALONS:[
		{
			"text":"You found talons! ",
			"image":ItemCollection.textures[ItemCollection.TALONS],
			"text2":" You can use these as a weapon."
		},
		{
			"text":"To equip them, press I to open your inventory, or use the shift keys to change your equipped item."
		}
	],
	ItemCollection.NECTAR:[
		{
			"text":"You found nectar! ",
			"image":ItemCollection.textures[ItemCollection.NECTAR],
			"text2":" Drinking these is good for your health. You can press I to open your inventory."
		}
	],
	ItemCollection.SCROLL_FRAGMENT: [
		{
			"text":"It's in the Old Tongue.",
			"speaker":"Player"
		},
		{
			"text":"I should've paid more attention in class.",
			"speaker":"Player"
		}
	]
}

func has_message(item : Variant) -> bool:
	if ItemCollection.is_scroll_fragment(item):
		return true
	return (messages_shown.get(item) != null)

func message_shown(item : Variant) -> bool:
	if ItemCollection.is_scroll_fragment(item):
		item = ItemCollection.SCROLL_FRAGMENT
	var shown = messages_shown.get(item)
	if shown != null:
		return shown
	return true
	
func show_message(item):
	if ItemCollection.is_scroll_fragment(item):
		#breakpoint
		Dialogue.open_dialogue.emit(messages[ItemCollection.SCROLL_FRAGMENT])
		messages_shown[ItemCollection.SCROLL_FRAGMENT] = true
	else:
		Dialogue.notify_player.emit(messages[item])
		messages_shown[item] = true
			
func load_completed_tutorial_prompts(completed):
	for c in completed:
		messages_shown[int(c)] = true
		#if c == ItemCollection.SCROLL_FRAGMENT:
			#breakpoint
	
func get_completed_tutorial_prompts():
	var completed = []
	for key in messages_shown:
		if messages_shown[key]:
			completed.append(int(key))
	return completed
	
