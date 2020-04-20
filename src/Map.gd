extends Node2D

var globals
var patches_covered = []
var patch_size = 3
var rect_patch_offset
var objects
var obj_layer
var tile_layers = []
var startpos

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

var fertypes = [1, 19] # tile types on which flowers can grow
# dictionary with coordinates => level of all (top-level) fertile tiles
var fertiles = {}
var fertile_array = []

func _ready():
	randomize()
	globals = get_node("/root/Globals")
	objects = $"/root/Game/Objects"
	globals.rows_and_cols = globals.screen_size / globals.grid_size
	globals.patch_size = max(globals.screen_size.x / globals.grid_size.x, globals.screen_size.y / globals.grid_size.y)
	if int(globals.patch_size) % 2 == 0:
		globals.patch_size += 1
	var tile_layer_basename = "Tile Layer "
	for c in range(1, get_child_count() + 1):
		var maybe_tile_layer = get_node_or_null(tile_layer_basename + str(c))
		if maybe_tile_layer != null:
			tile_layers.append(maybe_tile_layer)
			for cell_coords in maybe_tile_layer.get_used_cells():
				var tile = get_tile_at_level(cell_coords, c)
				if tile != -1 and not tile in fertypes:
					# higher tile that is non-empty and non-fertile
					fertiles.erase(cell_coords)
				elif tile in fertypes:
					fertiles[cell_coords] = c
	fertile_array = fertiles.keys()
	random_flowers()
	var startpos_node = $"Other/Startpos".get_child(0)
	var startrect = startpos_node.position
	startpos = Globals.tiled_to_diam(startrect)
	$"/root/Game/Schaap".set_coords(startpos)
	$Flowers.visible = false
	$Other.visible = false

func is_water(tile_id):
	return tile_id == 13 or tile_id == 14

func spawn_flower(coords):
	if objects.get_objects(coords) != null:
		return # tile is occupied
	var flower = Flower_scene.instance()
	if randf() > Globals.difficulty:
		flower.animation = "flower_good"
	else:
		flower.animation = "flower_bad"
		flower.set_random_frame()
	var layer_idx = fertiles[coords]
	flower.set_coords(coords, layer_idx)
	$"/root/Game/Objects".add_object(coords, flower)

func spawn_flowers():
	print("spawning")
	var good_tex_rect = $"Other/GoodFlower".get_child(0).region_rect
	var bad_tex_rect = $"Other/BadFlower".get_child(0).region_rect
	var flower_layers = get_node("Flowers").get_children()
	for flower_layer in flower_layers:
		var flower_children = flower_layer.get_children()
		for flower_obj in flower_children:
			print(flower_obj)
			var diam_coords = Globals.tiled_to_diam(flower_obj.position)
			var new_flower = Flower_scene.instance()
			if flower_obj.region_rect == good_tex_rect:
				new_flower.set_animation("flower_good")
			else:
				new_flower.set_animation("flower_bad")
			objects.add_object(diam_coords, new_flower)

func random_flowers():
	for flower_coords in fertiles.keys():
		if randi() % 8 == 0:
			var flower = Flower_scene.instance()
			if randf() > 0.5:
				flower.animation = "flower_good"
			else:
				flower.animation = "flower_bad"
			flower.set_random_frame()
			var layer_idx = fertiles[flower_coords]
			flower.set_coords(flower_coords, layer_idx)
			$"/root/Game/Objects".add_object(flower_coords, flower)

func flower_count_around(coords, range_param = 3):
	var flower_count = 0
	for x in range(coords.x - 3, coords.x + 4):
		for y in range(coords.y - 3, coords.y + 4):
			if objects.get_objects(Vector2(x, y)) != null:
				flower_count += 1
	return flower_count
			
# find fertile tiles and spawn depending on the number of flowers nearby
func maybe_spawn_flowers(max_flowers = 5, max_in_area = 4):
	for f in max_flowers:
		var rand_idx = randi() % fertile_array.size()
		var rand_coords = fertile_array[randi() % fertile_array.size()]
		if objects.get_objects(rand_coords) == null and flower_count_around(rand_coords) <= max_in_area:
			spawn_flower(rand_coords)

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
	for lvl_idx in range(tile_layers.size(), 0, -1):
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
		HIGH: [HIGH],
		LOW: [LOW],
		CW_DOWN: [CW_UP],
		CW_UP: [CW_DOWN],
		WATER: [],
		EMPTY: []
	}
	var conn_up = {
		HIGH: [LOW],
		LOW: [WATER],
		CW_DOWN: [],
		CW_UP: [],
		WATER: [],
		EMPTY: []
	}
	var conn_down = {
		HIGH: [],
		LOW: [HIGH],
		CW_DOWN: [],
		CW_UP: [],
		WATER: [],
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
			$"/root/Game/Audio/select".play()
			var tile_coords
			var the_tile
			for layer_idx in range(tile_layers.size(), 0, -1):
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
		
