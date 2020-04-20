extends Control

func _ready():
	OS.set_window_size(Globals.stretch_size)
	Globals.game_over = false
	Globals.distance_covered = 0
	Globals.flowers_eaten = 0
	Globals.paused = true
	Globals.difficulty = 0

func _on_Schaap_show_game_over():
	get_tree().change_scene("res://src/Screens/EndScreen.tscn")
