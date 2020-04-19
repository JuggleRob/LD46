# movement functionality from https://fornclake.com/2019/03/grid/
extends AnimatedSprite

class_name Actor

var diam_coords = Vector2()
var current_level = null
var height_offset_base = Vector2(0, -12)
var height_offset = height_offset_base # y-offset, be higher on high levels 

# Set diamond coordinates
# Level is automatically adjusted from previous level, unless given as an argument
func set_coords(diam_coords, level = null):
	self.diam_coords = diam_coords
	var levels = $"/root/Game/Map".get_children()
	if level != null:
		self.current_level = level
	# set default lowest possible level
	elif level == null and self.current_level == null:
		for lvl_idx in levels.size():
			var lowest_cell = levels[lvl_idx].get_cell(diam_coords.x, diam_coords.y)
			if lowest_cell != -1:
				self.current_level = lvl_idx
				break
	height_offset = height_offset_base + current_level * Vector2(0, -7)
	position = Globals.diam_to_rect(diam_coords) * Globals.grid_size + height_offset
