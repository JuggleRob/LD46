extends Node2D

var globals
var patches_covered = []
var patch_size = 3
var rect_patch_offset
var objects = {} # dictionary of coordinates to objects such as flowers

var Flower = preload("res://src/Flowers/Flower.tscn")

func _ready():
	globals = get_node("/root/Globals")
	globals.rows_and_cols = globals.screen_size / globals.grid_size
	globals.patch_size = max(globals.screen_size.x / globals.grid_size.x, globals.screen_size.y / globals.grid_size.y)
	if int(globals.patch_size) % 2 == 0:
		globals.patch_size += 1
	position.y += globals.tile_size.y * 0.75
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
					var cell_idxs = Vector2(x + center_cell_idxs.x, y + center_cell_idxs.y)
					$"Tile Layer 1".set_cell(cell_idxs.x, cell_idxs.y, tile_type)
					if x == 0 and y == 0:
						$"Tile Layer 1".set_cell(cell_idxs.x, cell_idxs.y, 1)
						# maybe add a flower:
						var flower = Flower.instance()
						flower.position = cell_idxs * globals.tile_size
						add_child(flower)
						if objects.get(cell_idxs) == null:
							objects[cell_idxs] = []
						objects[cell_idxs].append(flower)
					
			patches_covered.append(neighbor_offset)

func _process(delta):
	var camera_pos = get_node("/root/Game/Camera2D").offset
	var new_rect_patch_offset = Vector2(floor(0.5 + (camera_pos.x / (globals.patch_size * globals.grid_size.x))), floor(0.5 + (camera_pos.y / (globals.patch_size * globals.grid_size.y))))
	if new_rect_patch_offset != rect_patch_offset:
		rect_patch_offset = new_rect_patch_offset
		var diamond_patch_offset = Vector2(new_rect_patch_offset.x + new_rect_patch_offset.y, new_rect_patch_offset.y - new_rect_patch_offset.x)
		generate_patches(diamond_patch_offset)

func return_paths(visited):
	var paths = {}

func bfs(src: Vector2, tgt: Vector2):
	# combine neighbour_x and neighbour_y to get the coordinates for a possible neighbour
#	var neighbour_x = [-1,1,0,0]
#	var neighbour_y = [0,0,+1,-1]
	var connect_4 = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]
	var visited = {} # Dictionary with keys Vector2 and value another Dictionary
	var shortest_dist = 1000000
	var current_dist = 0
	var queue = {
		current_dist: [{
			"coords": src,
			"dist": 0,
			"back_ptr": null,
			"flower": false
		}]
	}
	while queue.size() > 0:
		var nodes_at_min_dist = queue.get(current_dist, [])
		if nodes_at_min_dist.size() == 0:
			queue.erase(current_dist)
			current_dist += 1
			continue
		var current_node = nodes_at_min_dist.pop_front()
		visited[current_node.coords] = current_node
		for obj in objects.get(current_node.coords, []):
			if obj is Flower:
				shortest_dist = current_node.dist
				current_node.flower = true
				continue # No need to add neighbors, they are farther away
		# Queue neighbors, add coords, dist and back_ptr
		var neighbors = []
		for dir in connect_4:
			neighbors.append(current_node.coords + dir)
		for coords in neighbors:
#			if visited.get()
			pass
