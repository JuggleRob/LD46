extends Control

var globals

func _ready():
	globals = get_node("/root/Globals")
	OS.set_window_size(globals.stretch_size)
	for idx in range(5):
		var gridpos = Vector2(randi() % 5, randi() % 5)
#	$Schaap.set_destination(Vector2(400, 400))
