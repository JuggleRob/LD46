# movement functionality from https://fornclake.com/2019/03/grid/
extends Node2D

class_name Actor

var diam_coords = Vector2()
var current_level = null
var height_offset_base = Vector2()
var height_offset = height_offset_base # y-offset, be higher on high levels 

# Set diamond coordinates
# Level is automatically adjusted from previous level, unless given as an argument
func set_coords(diam_coords, level = null):
	if level != null:
		var map = $"/root/Game/Map"
		for layer in map.get_children():
			print(layer.get_cell(diam_coords.x, diam_coords.y))
	self.diam_coords = diam_coords
	var levels = $"/root/Game/Map".get_children()
	# set default lowest possible level
	if level == null and self.current_level == null:
		for lvl_idx in levels.size():
			var lowest_cell = levels[lvl_idx].get_cell(diam_coords.x, diam_coords.y)
			if lowest_cell != -1:
				self.current_level = lvl_idx
				break
	height_offset = height_offset_base + current_level * Vector2(0, -7)
	print("set position with offset " + str(height_offset))
	print("diam " + str(diam_coords))
	position = Globals.diam_to_rect(diam_coords) * Globals.grid_size + height_offset
