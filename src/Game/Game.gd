extends Control

var globals

func _ready():
	globals = get_node("/root/Globals")
#	$"map test_diamond".position = Vector2(5, -10) * globals.tile_size
	var window_size = globals.screen_size # get_viewport().size
	var cell_size = window_size / globals.rows
	$Flowers.add_flower(Vector2(0, 0))
	for idx in range(5):
		var gridpos = Vector2(randi() % 10, randi() % 10)
		$Flowers.add_flower(gridpos)

