extends Node

var screen_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
var stretch_size = Vector2(4 * screen_size)
var tile_size = Vector2(28, 21)
var grid_size = Vector2(28, 14)
var rows_and_cols = Vector2()
var patch_size
