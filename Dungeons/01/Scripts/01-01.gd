extends Node2D

@export var music = "res://Music/DungeonMusic.ogg"
@onready var shelf = $Pots/FirstShelf
var searching_shelf = false
var save_info = {
	"pots":[],
	"NPCs":[],
	"items":{Collectible.TREASURE:[]},
	"cutscenes":{"collected_first_scroll_fragment":false}
	}
	
var search_shelf_dialogue = [
	{
		"text":"Looks like the military picked it clean.",
		"speaker":"Player"
	},
	{
		"text":"Hey, wait... Seems they didn't get everything.",
		"speaker":"Player"
	}
]

func on_shelf_searched():
	if not save_info["cutscenes"]["collected_first_scroll_fragment"]:
		save_info["cutscenes"]["collected_first_scroll_fragment"] = true
		Dialogue.open_dialogue.emit(search_shelf_dialogue)
		searching_shelf = true
	
func _ready():
	shelf.searched.connect(on_shelf_searched)
	
func _process(_delta):
	if searching_shelf:
		if not get_tree().get_nodes_in_group("Player")[0].in_dialogue:
			Collectible.collect_scroll_fragment(-1)
			searching_shelf = false
