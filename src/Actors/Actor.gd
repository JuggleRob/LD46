# movement functionality from https://fornclake.com/2019/03/grid/
extends Node2D

class_name Actor

export var speed = 1
var move_dir = Vector2() # move direction in diamond coordinates
var diam_coords = Vector2()
var round_diam_coords = Vector2()
var current_level = 1.0
var height_offset = Vector2() # y-offset, be higher on high levels 

# Set diamond coordinates
func set_coords(diam_coords, level = null):
	if level != null:
		var map = $"/root/Game/Map"
		for layer in map.get_children():
			print(layer.get_cell(diam_coords.x, diam_coords.y))
	self.diam_coords = diam_coords
	# interpolate between four nearest tiles to get effective height
	var neighbors = []
	neighbors.append(Vector2(floor(diam_coords.x), floor(diam_coords.y)))
	neighbors.append(Vector2(floor(diam_coords.x), ceil(diam_coords.y)))
	neighbors.append(Vector2(ceil(diam_coords.x), ceil(diam_coords.y)))
	neighbors.append(Vector2(ceil(diam_coords.x), ceil(diam_coords.y)))
	self.round_diam_coords = Vector2(round(diam_coords.x), round(diam_coords.y))
	position = Globals.diam_to_rect(diam_coords) * Globals.grid_size + height_offset

func after_move(delta):
	pass

# Gets called every frame
func _process(delta: float) -> void:
	diam_coords += delta * speed * move_dir
	set_coords(diam_coords + delta * speed * move_dir)
	self.after_move(delta)
