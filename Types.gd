extends Node

# Why on earth do I have this file here? Why is it just called "Types?"
#  Because I made this while I was still learning how inheritance and OOP abstractions
#  work in Godot (and in general) and everything here is only used in a small part
#  of the game, so I don't think cleaning it up is worth the trouble.

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
	var inventory : Dictionary[int,int]
	var documents : Array[Dictionary]
	func init():
		level = 1
		attack_damage = 1
		position = Vector2()
		life = 3
		temporary_life = 0
		total_life = 0
		inventory = {}

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
