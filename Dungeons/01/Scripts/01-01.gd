extends Room

@onready var shelf = $Pots/FirstShelf
var searching_shelf = false
var player_start_position = Vector2(-250.0, 0.0)
enum 
{
	SHELF_SEARCH_CUTSCENE
}

	
func _ready():
	get_parent().music.volume_db = -7.3
	save_data["cutscenes"] = [ {"collected_first_scroll_fragment":false} ]

func _process(_delta):
	var parent = get_parent()
	parent.music.volume_db = music_volume
