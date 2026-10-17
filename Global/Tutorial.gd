extends Node
@warning_ignore("unused_signal")
signal message_ended
const controller_icon_path = "res://Assets/UI/ControllerIcons/"
var controller_icons : Dictionary[StringName, String] = {
	"Click" : controller_icon_path + "Click.tres",
	"Attack" : controller_icon_path + "Attack.tres",
	"Inventory" : controller_icon_path + "Inventory.tres",
	"Switch Equipped Left" : ""
}

var messages_shown = {
		"letter_from_professor" : false,
		ItemCollection.TALONS : false,
		ItemCollection.NECTAR : false,
		ItemCollection.SCROLL_FRAGMENT : false,
		ItemCollection.GOLDEN_DAGGER : false
}

var messages = {
	ItemCollection.TALONS:[
		"You found talons! [img]" + ItemCollection.icon_paths[ItemCollection.TALONS] + "[/img] You can use these as a weapon.",
		"To equip them, press [img]" + controller_icons["Inventory"] + "[/img] for inventory, or use the shift keys to change your equipped item."
	],
	ItemCollection.NECTAR:[
		"You found nectar! [img]" + ItemCollection.icon_paths[ItemCollection.NECTAR] + "[/img]",
		"Drinking these is good for your health. [img]" + controller_icons["Inventory"] + "[/img] to open your inventory."
	],
	ItemCollection.GOLDEN_DAGGER:[
		"You found a weapon! [img]" + ItemCollection.icon_paths[ItemCollection.GOLDEN_DAGGER] + "[/img]",
		"[img]" + controller_icons["Attack"] + "[/img] to attack."
	]
}
	
func get_controller_icon_string(action : StringName):
	return "[img]" + controller_icons[action] + "[/img]"
	
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
	if messages_shown.get(item) == null:
		return
	if not messages_shown[item]:
		# Sometimes the tutorial stuff is handled elsewhere.
		if messages.get(item) != null:
			Dialogue.notify_player.emit(messages[item])
			messages_shown[item] = true
	
func load_completed_tutorial_prompts(completed):
	for key in messages_shown:
		messages_shown[key] = false
	for c in completed:
		messages_shown[int(c)] = true
	
func get_completed_tutorial_prompts():
	var completed = []
	for key in messages_shown:
		if messages_shown[key]:
			if key is int or key is float:
				completed.append(int(key))
			else:
				completed.append(key)
	return completed
