extends Control

func _ready():
	OS.set_window_size(Globals.stretch_size)
	Globals.game_over = false

func _on_Schaap_show_game_over():
	get_tree().change_scene("res://src/Screens/EndScreen.tscn")
