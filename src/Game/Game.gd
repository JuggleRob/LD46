extends Control

func _ready():
	OS.set_window_size(Globals.stretch_size)
	$Schaap.set_coords(Vector2(8, 15))
