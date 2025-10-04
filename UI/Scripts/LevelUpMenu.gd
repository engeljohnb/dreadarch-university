extends Control
signal closed()

func close():
	closed.emit()
	queue_free()
	
func increase_life_total():
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.total_life += 1
	player.life = player.total_life
	var hud = get_tree().get_nodes_in_group("HUD")[0]
	hud.lifebar.set_life_total(player.total_life)
	close()
	
func increase_attack_damage():
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.attack_damage += 1
	close()

func _ready():
	$IncreaseAttackDamage.pressed.connect(increase_attack_damage)
	$IncreaseLifeTotal.pressed.connect(increase_life_total)
	$IncreaseLifeTotal.grab_focus()
