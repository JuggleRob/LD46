extends Node2D

var globals

func _ready():
	globals = get_node("/root/Globals")
	position.y += globals.tile_size.y / 2
	generate_patch(Vector2(0, 0))

func generate_patch(patch_offset):
	for col in range(globals.rows):
		for row in range(globals.rows):
			$"0".set_cell(row, col, 9)
