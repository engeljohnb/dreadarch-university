extends StaticBody2D
var interaction_message = "Z to talk"
var type = Types.NPC
var status = {"times_spoken_to":0,"paid":false}
var dialogues = [
[
	{
		"text":"Why, hallo.",
		"speaker":"Aelia"
	},
	{
		"text":"Seems my hydenne place is founde. Fret not, you may stay.",
		"speaker":"Aelia"
	},
	{
		"text":"It is swete to see som one who is not a mad crowe.",
		"speaker":"Aelia"
	},
	{
		"text":"If it is lief, I wolde ask you to kepe this spot hyd.",
		"speaker":"Aelia"
	},
	{
		"text":"Take this for the kyndness. It is all I have.",
		"speaker":"Aelia"
	},
	{
		"text":"It is olde, but it sholde still be bracing.",
		"speaker":"Aelia"
	}
],
[
	{
		"text":"This is probably a stupid question, but... Are you a ghost?",
		"speaker":"Player"
	},
	{
		"text":"I wolde tell you if I coulde know myself, but I can say only that som thing binds me to this wrecked bochus.",
		"speaker":"Aelia"
	},
	{
		"text":"I am Aelia. In life I was a leche of alchymie for the King.",
		"speaker":"Aelia"
	},
	{
		"text":"The tidings of my work were kept hyd, but that matters little now.",
		"speaker":"Aelia"
	},
	{
		"text":"If you seek more nectar, I have none, but there may be som in my olde mede-roum.",
		"speaker":"Aelia"
	},
	{
		"text":"I will not go. I cannot brook these wicked crowes.",
		"speaker":"Aelia"
	}
],
[
	{
		"text":"Drede not that I will ask of your bisynes in this place, but I own there are som things I wonder on.",
		"speaker":"Aelia"
	},
	{
		"text":"Tell me, has the kingdom thriven since the king was slayn?",
		"speaker":"Aelia"
	},
	{
		"text":"Slain?",
		"speaker":"Player"
	},
	{
		"text":"I don't think we're even the same kingdom anymore.",
		"speaker":"Player"
	},
	{
		"text":"I understonde.",
		"speaker":"Aelia"
	},
	{
		"text":"Then so long is passed that tidings of the broader world have no worth for me.",
		"speaker":"Aelia"
	}
]
]

var use_dialogue = [
	{
		"text":"You shoulde keep your things. I have no use for them.",
		"speaker":"Aelia"
	}
]

var translate_dialogue = [
	{
		"text":"It is a wonder that you founde this olde scrap.",
		"speaker":"Aelia"
	},
	{
		"text":"It was writen by Herr Severus. I did not like him then, but now I think back on our time kyndly.",
		"speaker":"Aelia"
	},
	{
		"text":"This is what it says in the Common Tonge:",
		"speaker":"Aelia"
	},
	{
		"text":"\"Aelia, let go of your fey work to make the nectar of Juppiter.",
		"speaker":"Aelia"
	},
	{
		"text":"You have not seen sped, and your cursed bees fill my work roum and make it so I cannot think. I beg you.\"",
		"speaker":"Aelia"
	},
	{
		"text":"Wel, I do not think it is what Juppiter drinks, but I wolde hardely call it \"fey.\"",
		"speaker":"Aelia"
	},
	{
		"text":"And I would hardly call your speech the \"Common Tongue.\"",
		"speaker":"Player"
	}
]

func activate(_using_item = "", _count = 0):
	if (status["times_spoken_to"] >= 1) and (not _using_item.is_empty()):
		if _using_item is Dictionary:
			var text = _using_item.get("latin_text")
			if text:
				if text.contains("Aelia"):
					Dialogue.open_dialogue.emit(translate_dialogue)
					return
		Dialogue.open_dialogue.emit(use_dialogue)
		return
	if not status["times_spoken_to"] >= dialogues.size():
		Dialogue.open_dialogue.emit(dialogues[status["times_spoken_to"]])
		status["times_spoken_to"] += 1
		return
	else:
		Dialogue.open_dialogue.emit(dialogues[-1].slice(-1, dialogues[-1].size()))
		
func _process(_delta):
	if Dialogue.current_box == dialogues[0][-1]:
		if not status["paid"]:
			status["paid"] = true
			Collectible.item_collected.emit(Collectible.NECTAR, 5, true)
