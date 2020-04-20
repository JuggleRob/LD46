# movement functionality from https://fornclake.com/2019/03/grid/
extends AnimatedSprite

class_name Actor

var diam_coords = Vector2()
var current_level = null
var height_offset = Globals.height_offset_base # y-offset, be higher on high levels 

# Set diamond coordinates
# Level is automatically adjusted from previous level, unless given as an argument
func set_coords(diam_coords, level = null):
	self.diam_coords = diam_coords
	if level != null:
		self.current_level = level
		return
	else:
		var levels = $"/root/Game/Map".tile_layers
		# adjust if moving to an adjacent level
		for lvl_idx in range(levels.size(), 0, -1):
			var lowest_cell = levels[lvl_idx - 1].get_cell(diam_coords.x, diam_coords.y)
			if lowest_cell != -1:
				self.current_level = lvl_idx
				break
	if current_level == null:
		current_level = 1
	height_offset = Globals.height_offset_base + current_level * Vector2(0, -7)
	position = Globals.diam_to_rect(diam_coords) * Globals.grid_size + height_offset
