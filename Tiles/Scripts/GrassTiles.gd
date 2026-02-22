extends TileMapLayer
signal player_entered_grass()
signal player_exited_grass()

# Since a SceneCollection tilemap can't use custom data layers the same way as 
#  other TileMapLayers, I need a convoluted set of signals to determine whether the player is
#  currently in the grass.
# If one second goes by without the player entering any grass tiles, the player is out of the grass.
var player_in_grass = false
var grass_timer = 0.0

func connect_stupid_signals():
	for child in get_children():
		child.has_player.connect(on_has_player)
		
func _ready():
	call_deferred("connect_stupid_signals")
			
func on_has_player():
	if not player_in_grass:
		player_in_grass = true
		player_entered_grass.emit()

func _process(_delta):
	if player_in_grass:
		grass_timer += _delta
		if grass_timer >= 1.0:
			player_in_grass = false
			player_exited_grass.emit()
			grass_timer = 0.0
