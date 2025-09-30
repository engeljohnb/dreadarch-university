extends StaticBody2D

# Gotta be a dictionary for game saves
var status = {
	"gone" : false,
	"introduced" : false,
	"offered_failed_bribe" : false
}
var interaction_message = "Z to Talk"
var will_retire = false
var retiring = false
var retiring_timer = 0.0
var retiring_duration = 6.0
var type = Types.NPC
var paid = false


var using_item_default_dialogue = [
	{
		"text" : "Go play with that thing somewhere else!",
		"speaker" : "Fitzroy"
	}
]

var intro_dialogue = [
	{
		"text" : "!!!",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "You shouldn't be here! It's dangerous.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "I need to go in there. I'm trying to find my Professor.",
		"speaker" : "Player"
	},
	{
		"text" : "Nope! Not happening! No one goes in by orders of Captain Geralt.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Uh... well... ",
		"speaker" : "Player"
	},
	{
		"text" : "I'm helping with the excavation. I'm supposed to go in there.",
		"speaker" : "Player"
	},
	{
		"text" : "Nice try.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Can't you make an exception? I won't tell Captain Whoever.",
		"speaker" : "Player"
	},
	{
		"text" : "When you're the one paying my salary, I'll do what you say. Until then, what the Captain says goes.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "You really should leave. There are monsters down here! This isn't kid stuff.",
		"speaker" : "Fitzroy"
	}
]

var failed_bribe_dialogue = [
	{
		"text" : "If you're going to bribe me, it's going to take more than THAT!",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "But these aren't just coins! They're priceless archeological artifacts.",
		"speaker" : "Player"
	},
	{
		"text" : "Hey, remember my job's on the line here!",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Come back when you have enough to make me rich.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "I think 25 should do it.",
		"speaker" : "Fitzroy"
	}
]

var failed_bribe_dialogue2 = [
	{
		"text" : "I already told you, if you want to bribe me, it has to be worth the court martial.",
		"speaker" : "Fitzroy"
	}
]

var fresh_adequate_bribe_dialogue = [
	{
		"text" : "If you're going to bribe me, it's going to take more than THAT!",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "But these aren't just coins! They're priceless archeological artifacts.",
		"speaker" : "Player"
	},
	{
		"text" : "Priceless, huh?",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Well... that is a lot.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "...",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Oh, devil take it. I'm off to see the world.",
		"speaker" : "Fitzroy"
	}
]

var adequate_bribe_dialogue = [
	{
		"text" : "Wow... now THAT'S a lot.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "I didn't think you'd actually pull it off.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Oh, devil take it. I'm off to see the world.",
		"speaker" : "Fitzroy"
	}
]

var retiring_dialogue = [
	{
		"text" : "I hope you know what I'm doing here is a big deal.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "If they ever find me I could get court martialed.",
		"speaker" : "Fitzroy"
	},
	{
		"text" : "Sure.",
		"speaker" : "Player"
	},
	{
		"text" : "Giving away priceless artifacts is also a big deal.",
		"speaker" : "Player"
	},
	{
		"text" : "You'd just better be right about the 'priceless' part.",
		"speaker" : "Fitzroy"
	}
]

func _ready():
	$AnimatedSprite2D.play("Idle")

func offering_inadequate_bribe(using_item, item_count):
	return ((using_item == Collectible.TREASURE) and 
	(item_count < 25))

func offering_adequate_bribe(using_item, item_count):
	return ((using_item == Collectible.TREASURE) and 
	(item_count >= 25))
	
func activate(using_item = "", item_count = 1):
	if retiring:
		Dialogue.open_dialogue.emit(retiring_dialogue)
		return
	if not status["introduced"]:
		Dialogue.open_dialogue.emit(intro_dialogue)
		status["introduced"] = true
		return
	if offering_inadequate_bribe(using_item, item_count):
		if status["offered_failed_bribe"]:
			Dialogue.open_dialogue.emit(failed_bribe_dialogue2)
		else:
			Dialogue.open_dialogue.emit(failed_bribe_dialogue)
			status["offered_failed_bribe"] = true
		return
	elif offering_adequate_bribe(using_item, item_count):
		if status["offered_failed_bribe"]: 
			Dialogue.open_dialogue.emit(adequate_bribe_dialogue)
		else:
			Dialogue.open_dialogue.emit(fresh_adequate_bribe_dialogue)
		will_retire = true
		return
	elif status["introduced"]:
		if (not using_item.is_empty()) and (using_item != Collectible.TREASURE):
			Dialogue.open_dialogue.emit(using_item_default_dialogue)
		else:
			Dialogue.open_dialogue.emit(intro_dialogue.slice(-2, intro_dialogue.size()))
		
func _process(_delta):
	if will_retire:
		if Dialogue.current_box["text"] == adequate_bribe_dialogue[-1]["text"]:
			if not paid:
				Collectible.item_collected.emit(Collectible.TREASURE, -25, true)
				paid = true
		if not get_tree().get_nodes_in_group("Player")[0].in_dialogue:
			retiring = true
			will_retire = false
			status["gone"] = true
			$AnimatedSprite2D.play("Walk Left")
	if retiring:
		if get_tree().get_nodes_in_group("Player")[0].in_dialogue:
			$AnimatedSprite2D.play("Idle")
		else:
			retiring_timer += _delta
			if retiring_timer >= (retiring_duration):
				$AnimatedSprite2D.modulate.a -= _delta
			if $AnimatedSprite2D.modulate.a <= 0:
				visible = false
				$CollisionShape2D.set_deferred("disabled", true)
			if $AnimatedSprite2D.animation != "Walk Left":
				$AnimatedSprite2D.play("Walk Left")
			position.x -= (100*_delta)
		
