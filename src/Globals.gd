extends Node

var screen_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
var stretch_size = Vector2(4 * screen_size)
const tile_size = Vector2(28, 21)
const grid_size = Vector2(28, 14)
var rows_and_cols = Vector2()
var patch_size
var game_over = false
var paused = true
const height_offset_base = Vector2(0, -5)
const mouse_offset = Vector2(0, -21)

var flowers_eaten = 0
var distance_covered = 0

func rect_to_diam(v):
	return Vector2(v.x + v.y, v.y - v.x)
	
func diam_to_rect(v):
	return 0.5 * Vector2(v.x - v.y, v.x + v.y)

func tiled_to_diam(v):
	print("converting...")
	var converted = (v / Vector2(grid_size.y, grid_size.y))
	return converted
