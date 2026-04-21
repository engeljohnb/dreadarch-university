extends Node

# For some reason, defining a "new" function on these classes
#  breaks the JSON serializer used for game saves.
#  So they have init. use it like:
#		save = Save.new()
#		save.init()
#	not like:
#		save = Save.init()
class Player:
	var level : int
	var attack_damage : int
	var position: Vector2
	var life: int
	var temporary_life : int
	var total_life: int
	# Guess it has to be a dictionary bc for some reason the JSON serializer can do Class.Class, but not Class.Class.Class
	var inventory: Dictionary
	func init():
		level = 1
		attack_damage = 1
		position = Vector2()
		life = 3
		temporary_life = 0
		total_life = 0
		inventory = {
			Collectible.SCROLL_FRAGMENT : [],
			Collectible.TREASURE : int(0),
			Collectible.TALONS: int(0),
			Collectible.GOLDEN_DAGGER : int(0)
		}

class Save:
	var current_scene: String
	var current_scene_path : String
	var player: Player
	var rooms : Dictionary
	var completed_tutorial_prompts : Array
	func init():
		current_scene = "01-01"
		current_scene_path = "res://Dungeons/01/01-01.tscn"
		player = null
		rooms = {}
		completed_tutorial_prompts = []

class Room:
	extends Node2D
	@export var music : String = "res://Music/DungeonMusic.ogg"
	@export var music_volume : float = -7.3
	var save_data : Dictionary = {
		"pots":[],
		"NPCs":[],
		"items":{Collectible.TREASURE:[]}
	}
	func init_music():
		var music_track = Music.get_music_track_from_room_name(SceneTransition.current_scene_name)
		if not music_track.is_empty():
			music = music_track["path"]
			music_volume = music_track["volume"]

class Interactable:
	extends StaticBody2D
	var interaction_message = "Z to interact"
	func activate():
		print("Activated: ", self.name)
class NPC:
	extends Interactable
	var status = {"gone":false}
	# Implemented by subclasses
	func _init():
		pass
	func _ready():
		interaction_message = "Z to talk"
		call_deferred("init")
