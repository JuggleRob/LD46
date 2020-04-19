extends Control

var globals

func _ready():
	globals = get_node("/root/Globals")
	OS.set_window_size(globals.stretch_size)
