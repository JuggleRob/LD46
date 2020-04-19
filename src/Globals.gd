extends Node

var screen_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
var stretch_size = Vector2(4 * screen_size)
var tile_size = Vector2(28, 21)
var grid_size = Vector2(28, 14)
var rows_and_cols = Vector2()
var patch_size
var game_over = false
var height_offset_base = Vector2(0, -5)
var mouse_offset = Vector2(0, -21)

func rect_to_diam(v):
	return Vector2(v.x + v.y, v.y - v.x)
	
func diam_to_rect(v):
	return 0.5 * Vector2(v.x - v.y, v.x + v.y)
