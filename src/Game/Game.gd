extends Control

var globals

func _ready():
	globals = get_node("/root/Globals")
	OS.set_window_size(globals.stretch_size)
	$Flowers.add_flower(Vector2(0, 0))
	for idx in range(5):
		var gridpos = Vector2(randi() % 5, randi() % 5)
		$Flowers.add_flower(gridpos)
	$Flowers/Schaap.set_destination(Vector2(400, 400))
