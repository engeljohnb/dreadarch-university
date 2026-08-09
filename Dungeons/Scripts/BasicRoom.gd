extends Node2D
class_name Room
@export var music : String = "res://Music/DungeonMusic.ogg"
@export var music_volume : float = -7.3
@export var player_light_on = true
const TARGET_COLOR = Color(0.258, 0.287, 0.527)
var save_data : Dictionary = {
	"pots":[],
	"NPCs":[],
	"items":{int(ItemCollection.TREASURE):[]},
}
var total_enemies = 0
var exorcised = false

func init_music():
	var music_track = Music.get_music_track_from_room_name(SceneTransition.current_scene_name)
	if not music_track.is_empty():
		music = music_track["path"]
		music_volume = music_track["volume"]
		
func get_num_enemies() -> int:
	if get_node_or_null("Enemies") == null:
		return 0
	var children = get_node("Enemies").get_children()
	var c = children.size()
	for child in children:
		if child is not Enemy:
			continue
		if child.life <= 0:
			c -= 1
	return c
	
func _ready():
	total_enemies = get_num_enemies()
	
func notify_room_exorcised():
	print("Room Exorcised")
	
	
func update_exorcism():
	var num_enemies = get_num_enemies()
	#var ratio = float(num_enemies)/float(total_enemies)
	#modulate = lerp(Color(1,1,1), TARGET_COLOR, ratio)
	if num_enemies == 0:
		if not exorcised:
			exorcised = true
			if not SceneTransition.player_is_above_ground():
				notify_room_exorcised()
func _process(_delta):
	update_exorcism()
