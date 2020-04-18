extends Node2D

var globals
var patches_covered = []
var patch_size = 3
var rect_patch_offset

func _ready():
	globals = get_node("/root/Globals")
	globals.rows_and_cols = globals.screen_size / globals.grid_size
	globals.patch_size = max(globals.screen_size.x / globals.grid_size.x, globals.screen_size.y / globals.grid_size.y)
	if int(globals.patch_size) % 2 == 0:
		globals.patch_size += 1
	print(globals.patch_size)
	print(globals.rows_and_cols)
	position.y += globals.tile_size.y / 2
	rect_patch_offset = Vector2(0, 0)
	generate_patches(Vector2(0, 0))

# Generate a set of tiles large enough to fill the screen,
# at offset patch_offset in diamond grid coordinates.
func generate_patches(diamond_patch_offset):
	var neighbors = [Vector2(0, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
			Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)]
	for neighbor in neighbors:
		var neighbor_offset = diamond_patch_offset + neighbor
		if not neighbor_offset in patches_covered:
			var center_cell_idxs = globals.patch_size * neighbor_offset
			var tile_type = randi() % 9 + 1
			for x in range(-floor(globals.patch_size / 2), floor(globals.patch_size / 2) + 1):
				for y in range(-floor(globals.patch_size / 2), floor(globals.patch_size / 2) + 1):
					$"0".set_cell(x + center_cell_idxs.x, y + center_cell_idxs.y, tile_type)
			patches_covered.append(neighbor_offset)

func _process(delta):
	var camera_pos = get_node("/root/Game/Camera2D").offset
	var new_rect_patch_offset = Vector2(floor(0.5 + (camera_pos.x / (globals.patch_size * globals.grid_size.x))), floor(0.5 + (camera_pos.y / (globals.patch_size * globals.grid_size.y))))
	if new_rect_patch_offset != rect_patch_offset:
		rect_patch_offset = new_rect_patch_offset
		var diamond_patch_offset = Vector2(new_rect_patch_offset.x + new_rect_patch_offset.y, new_rect_patch_offset.y - new_rect_patch_offset.x)
		generate_patches(diamond_patch_offset)
