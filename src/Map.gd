extends Node2D

var globals
var patches_covered = []
var patch_size = 3
var rect_patch_offset
var objects

var Flower_scene = preload("res://src/Flowers/Flower.tscn")

var HIGH = 0
var LOW = 1
var CW_DOWN = 2
var CW_UP = 3
var WATER = 4
var EMPTY = 5
var side_types = {
	1: [HIGH, HIGH, HIGH, HIGH],
	2: [CW_DOWN, LOW, CW_UP, HIGH],
	3: [HIGH, CW_DOWN, LOW, CW_UP],
	4: [CW_DOWN, CW_UP, HIGH, HIGH],
	5: [HIGH, CW_DOWN, CW_UP, HIGH],
	6: [LOW, CW_UP, HIGH, CW_DOWN],
	7: [CW_UP, HIGH, CW_DOWN, LOW],
	8: [HIGH, HIGH, CW_DOWN, CW_UP],
	9: [CW_DOWN, LOW, LOW, CW_UP],
	10: [CW_UP, CW_DOWN, LOW, LOW],
	11: [LOW, LOW, CW_UP, CW_DOWN],
	12: [EMPTY, EMPTY, EMPTY, EMPTY],
	13: [WATER, WATER, WATER, WATER],
	14: [WATER, WATER, WATER, WATER],
	15: [HIGH, HIGH, HIGH, HIGH],
	16: [EMPTY, EMPTY, EMPTY, EMPTY],
	17: [WATER, HIGH, WATER, HIGH],
	18: [HIGH, WATER, HIGH, WATER],
	19: [HIGH, HIGH, HIGH, HIGH],
	20: [EMPTY, EMPTY, EMPTY, EMPTY]
}

func _ready():
	randomize()
	globals = get_node("/root/Globals")
	objects = $"/root/Game/Objects"
	globals.rows_and_cols = globals.screen_size / globals.grid_size
	globals.patch_size = max(globals.screen_size.x / globals.grid_size.x, globals.screen_size.y / globals.grid_size.y)
	if int(globals.patch_size) % 2 == 0:
		globals.patch_size += 1
	rect_patch_offset = Vector2(0, 0)
#	generate_patches(Vector2(0, 0))
	spawn_flowers()

func is_water(tile_id):
	return tile_id == 13 or tile_id == 14

# spawn flowers on existing tiles, in a 60x60 area around the origin.
func spawn_flowers():
# maybe add a flower:
	var layers = self.get_children()
	for x in range(-30, 30):
		for y in range(-30, 30):
			for layer_idx in range(layers.size(), 0, -1):
				var layer = layers[layer_idx - 1]
				var tile_type = layer.get_cell(x, y)
				if tile_type != -1 and not is_water(tile_type):
					if randi() % 8 == 0:
						var flower = Flower_scene.instance()
						if randf() > 0.5:
							flower.animation = "flower_good"
						else:
							flower.animation = "flower_bad"
						flower.set_random_frame()
						var flower_coords = Vector2(x, y)
						flower.set_coords(flower_coords, layer_idx)
						$"/root/Game/Objects".add_object(flower_coords, flower)
					# found the top tile, don't process lower ones
					break
					
#	if cell_idxs.y == 2 and cell_idxs.x == 4 or \
#		cell_idxs.y == 2 and cell_idxs.x == -3:
#		if base_layer.get_cell(cell_idxs.x, cell_idxs.y) != 14:
#			var flower = Flower_scene.instance()
#			if randf() > 0.5:
#				flower.animation = "flower_good"
#			else:
#				flower.animation = "flower_bad"
#			flower.set_random_frame()
#			$"/root/Game/Objects".add_object(cell_idxs, flower)
#
#	if cell_idxs.x == 0 and cell_idxs.y == 0:
#		base_layer.set_cell(cell_idxs.x, cell_idxs.y, 10)
#		var flower = Flower_scene.instance()
#		$"/root/Game/Objects".add_object(cell_idxs, flower)
#		flower.set_coords(Vector2())
# Generate a set of tiles large enough to fill the screen,
# at offset patch_offset in diamond grid coordinates.
func generate_patches(diamond_patch_offset):
	var base_layer = $"Tile Layer 1"
	var neighbors = [Vector2(0, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
			Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)]
	for neighbor in neighbors:
		var neighbor_offset = diamond_patch_offset + neighbor
		if not neighbor_offset in patches_covered:
			var center_cell_idxs = globals.patch_size * neighbor_offset
			var tile_type = randi() % 9 + 1
			for x in range(-floor(globals.patch_size / 2), floor(globals.patch_size / 2) + 1):
				for y in range(-floor(globals.patch_size / 2), floor(globals.patch_size / 2) + 1):
					var cell_idxs = Vector2(x + center_cell_idxs.x, y + center_cell_idxs.y)
					base_layer.set_cell(cell_idxs.x, cell_idxs.y, tile_type)
					# Set some custom tiles for debugging
					
					if center_cell_idxs.x == 0:
						if cell_idxs.y == 1:
							base_layer.set_cell(cell_idxs.x, cell_idxs.y, 14)
						elif cell_idxs.y == 0 and cell_idxs.x == 1:
							base_layer.set_cell(cell_idxs.x, cell_idxs.y, 14)
						else:
							base_layer.set_cell(cell_idxs.x, cell_idxs.y, 1)
			patches_covered.append(neighbor_offset)

func _process(delta):
	var camera_pos = get_node("/root/Game/Camera2D").offset
	var new_rect_patch_offset = Vector2(floor(0.5 + (camera_pos.x / (globals.patch_size * globals.grid_size.x))), floor(0.5 + (camera_pos.y / (globals.patch_size * globals.grid_size.y))))
	if new_rect_patch_offset != rect_patch_offset:
		rect_patch_offset = new_rect_patch_offset
		var diamond_patch_offset = Globals.rect_to_diam(new_rect_patch_offset)
#		generate_patches(diamond_patch_offset)

func paths_to_targets(visited, tgts):
	var paths = []
	for tgt in tgts:
		var path = [tgt]
		var back_ptr = tgt.back_ptr
		while back_ptr != null:
			path.append(back_ptr)
			back_ptr = back_ptr.back_ptr
		path.invert()
		paths.append(path)
	return paths

func top_level(coords):
	for lvl_idx in range(self.get_children().size(), 0, -1):
		var layer_name = "Tile Layer " + str(lvl_idx)
		var layer = get_node(layer_name)
		var tile = layer.get_cell(coords.x, coords.y)
		if tile != -1:
			return lvl_idx
	return -1

func get_tile(coords):
	var tl = top_level(coords)
	return get_tile_at_level(coords, tl)

func get_tile_at_level(coords, lvl):
	var layer_name = "Tile Layer " + str(lvl)
	var layer = get_node(layer_name)
	return layer.get_cell(coords.x, coords.y)

# takes two (adjacent) coordinates and determines whether
# going from src to tgt is possible
func reachable(src, tgt):
	# arrays define side types, starting in the direction -y (right-up)
	# and going around clockwise.
	var dir = tgt - src
	var side_src_idx
	if dir == Vector2(0, -1):
		side_src_idx = 0
	elif dir == Vector2(1, 0):
		side_src_idx = 1
	elif dir == Vector2(0, 1):
		side_src_idx = 2
	elif dir == Vector2(-1, 0):
		side_src_idx = 3
	var side_tgt_idx = (side_src_idx + 2) % 4
	var conn_same = {
		HIGH: [HIGH, WATER],
		LOW: [LOW, WATER],
		CW_DOWN: [CW_UP],
		CW_UP: [CW_DOWN],
		WATER: [HIGH, LOW],
		EMPTY: []
	}
	var conn_up = {
		HIGH: [LOW, WATER],
		LOW: [WATER],
		CW_DOWN: [],
		CW_UP: [],
		WATER: [HIGH, LOW],
		EMPTY: []
	}
	var conn_down = {
		HIGH: [WATER],
		LOW: [HIGH, WATER],
		CW_DOWN: [],
		CW_UP: [],
		WATER: [HIGH, LOW],
		EMPTY: []
	}
	var src_lvl = top_level(src)
	var tgt_lvl = top_level(tgt)
	# two levels difference, can never be reachable
	if abs(src_lvl - tgt_lvl) > 1 or src_lvl == -1 or tgt_lvl == -1:
		return false
	else:
		var src_tile = get_tile_at_level(src, src_lvl)
		var tgt_tile = get_tile_at_level(tgt, tgt_lvl)
		var src_side = side_types[src_tile][side_src_idx]
		var tgt_side = side_types[tgt_tile][side_tgt_idx]
		if tgt_lvl == src_lvl + 1:
			if tgt_side in conn_up[src_side]:
				return true
		elif tgt_lvl == src_lvl - 1:
			if tgt_side in conn_down[src_side]:
				return true
		elif tgt_lvl == src_lvl:
			if tgt_side in conn_same[src_side]:
				return true
	return false

# Find a path to a specific coordinate, or to the nearest flower
func bfs(src: Vector2, tgt = null):
	# combine neighbour_x and neighbour_y to get the coordinates for a possible neighbour
#	var neighbour_x = [-1,1,0,0]
#	var neighbour_y = [0,0,+1,-1]
	var objects = $"/root/"
	var connect_4 = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]
	var shortest_dist = 1000000
	var first_node = {
		"coords": src,
		"dist": 0,
		"back_ptr": null,
		"flower": null
	}
	var queue = [first_node]
	var checked_nodes = {
		src: first_node
	}
	checked_nodes[first_node.coords] = first_node
	var flower_nodes = []
	var search_limit = 1000
	var search_count = 0
	while queue.size() > 0:
		search_count += 1
		if search_count == search_limit:
			print("Search took too long!")
			return []
		var current_node = queue.pop_front()
		for obj in objects.get(current_node.coords, []):
			if (tgt != null and current_node.coords == tgt) or \
					(tgt == null and obj is Flower):
				shortest_dist = current_node.dist
				current_node.flower = true
				flower_nodes.append(current_node)
				continue # No need to add neighbors, they are farther away
		# Queue neighbors, add coords, dist and back_ptr
		var neighbors = []
		for dir in connect_4:
			neighbors.append(current_node.coords + dir)
		for coords in neighbors:
			var maybe_checked = checked_nodes.get(coords)
			if maybe_checked == null and current_node.dist + 1 <= shortest_dist:
				if reachable(current_node.coords, coords):
					var new_checked = {
						"coords": coords,
						"dist": current_node.dist + 1,
						"back_ptr": current_node,
						"flower": null
					}
					checked_nodes[coords] = new_checked
					queue.append(new_checked)
	return paths_to_targets(checked_nodes, flower_nodes)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var tile_coords
			var the_tile
			for layer_idx in range(self.get_children().size(), 0, -1):
				var layer_name = "Tile Layer " + str(layer_idx)
				var layer = get_node(layer_name)
				# which layer we call this on does not matter, but the layer's
				# position (in the argument) does.
				tile_coords = layer.world_to_map( \
						event.position - \
						0.5 * Globals.screen_size - \
						Globals.mouse_offset + \
						$"/root/Game/Camera2D".offset - \
						layer.position
						)
				the_tile = get_tile_at_level(tile_coords, layer_idx)
				if the_tile != -1:
				# found the right coordinates, break (highlight would be nice)
					break
			objects.remove_objects(tile_coords)
		
