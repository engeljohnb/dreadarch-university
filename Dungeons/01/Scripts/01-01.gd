extends Types.Room

@onready var shelf = $Pots/FirstShelf
var searching_shelf = false
var player_start_position = Vector2(-250.0, 0.0)
enum 
{
	SHELF_SEARCH_CUTSCENE
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
	var cutscenes = save_data.get("cutscenes")
	if cutscenes != null:
		if save_data["cutscenes"][SHELF_SEARCH_CUTSCENE].get("collected_first_scroll_fragment") == false:
			save_data["cutscenes"][SHELF_SEARCH_CUTSCENE]["collected_first_scroll_fragment"] = true
			Dialogue.open_dialogue.emit(search_shelf_dialogue)
			searching_shelf = true
	
func _ready():
	shelf.searched.connect(on_shelf_searched)
	get_parent().music.volume_db = -7.3
	save_data["cutscenes"] = [ {"collected_first_scroll_fragment":false} ]

func _process(_delta):
	var parent = get_parent()
	parent.music.volume_db = music_volume

	if searching_shelf:
		if not get_tree().get_nodes_in_group("Player")[0].in_dialogue:
			Collectible.collect_scroll_fragment(-1)
			searching_shelf = false
