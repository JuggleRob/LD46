# movement functionality from https://fornclake.com/2019/03/grid/
extends Node2D

class_name Actor

export var speed = 1
var move_dir = Vector2() # move direction in diamond coordinates
var diam_coords = Vector2()
var round_diam_coords = Vector2()
var current_level = null
var height_offset = Vector2() # y-offset, be higher on high levels 

# Set diamond coordinates
# Level is automatically adjusted from previous level, unless given as an argument
func set_coords(diam_coords, level = null):
	if level != null:
		var map = $"/root/Game/Map"
		for layer in map.get_children():
			print(layer.get_cell(diam_coords.x, diam_coords.y))
	self.diam_coords = diam_coords
	# interpolate between four nearest tiles to get effective height

#	neighbors.append(Vector2(floor(diam_coords.x), floor(diam_coords.y)))
#	neighbors.append(Vector2(floor(diam_coords.x), ceil(diam_coords.y)))
#	neighbors.append(Vector2(ceil(diam_coords.x), ceil(diam_coords.y)))
#	neighbors.append(Vector2(ceil(diam_coords.x), ceil(diam_coords.y)))
#	position = Globals.diam_to_rect(diam_coords) * Globals.grid_size + height_offset

	self.round_diam_coords = Vector2(round(diam_coords.x), round(diam_coords.y))
	var levels = $"/root/Game/Map".get_children()
	# set default lowest possible level
	if current_level == null:
		for lvl_idx in levels.size():
			var lowest_cell = levels[lvl_idx].get_cell(round_diam_coords.x, round_diam_coords.y)
			if lowest_cell != -1:
				current_level = lvl_idx
				break
	var neighbor_coords = []
	neighbor_coords.append(Vector2(floor(diam_coords.x), floor(diam_coords.y)))
	neighbor_coords.append(Vector2(floor(diam_coords.x), ceil(diam_coords.y)))
	neighbor_coords.append(Vector2(ceil(diam_coords.x), ceil(diam_coords.y)))
	neighbor_coords.append(Vector2(ceil(diam_coords.x), ceil(diam_coords.y)))
	var average_level = 0
	for nc in neighbor_coords:
		for level_idx in levels.size():
			# Only consider nearby levels for averaging, cannot move to high/low ones.
			if level_idx >= current_level - 1 or level_idx <= current_level + 1:
				var cell = levels[level_idx].get_cell(nc.x, nc.y)
				if cell != null:
					var to_neighbor = nc - diam_coords
					average_level += to_neighbor.x * to_neighbor.y * level_idx
	self.current_level = average_level
	for n in neighbor_coords:
		var dist = (n - self.diam_coords).length()
		average_level += dist * 0
	self.round_diam_coords = Vector2(round(diam_coords.x), round(diam_coords.y))
	position = Globals.diam_to_rect(diam_coords) * Globals.grid_size + height_offset

func after_move(delta):
	pass

# Gets called every frame
func _process(delta: float) -> void:
	diam_coords += delta * speed * move_dir
	set_coords(diam_coords + delta * speed * move_dir)
	self.after_move(delta)
