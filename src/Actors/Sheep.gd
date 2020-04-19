extends Actor

var coords
var destination
var path
var next_path_node

func set_coords(coords):
	self.coords = coords
	self.position = coords * globals.grid_size

# set destination in diamond coordinates
func set_destination(dest):
	self.destination = dest
	if dest != null:
		var vec_diamond = self.destination - self.coords
		var move_vector_rect = globals.diam_to_rect(vec_diamond)
		move_dir = (move_vector_rect * globals.grid_size).normalized()
	else:
		move_dir = Vector2()
	if move_dir.x >= 0:
		self.scale.x = 1
	else:
		self.scale.x = -1 

func after_move(delta):
	var rect_coords = self.position / globals.grid_size
	var diam_coords = globals.rect_to_diam(rect_coords)
	var floored = Vector2(floor(diam_coords.x + 0.5), floor(diam_coords.y + 0.5))
	if floored != coords:
		coords = floored
	if destination == null:
		var paths = $"/root/Game/grass_test_slope".bfs(self.coords)
		if paths.size() > 0:
			path = paths[0]
			var dest = path.back()
			next_path_node = path.pop_front()
			if next_path_node != null:
				set_destination(next_path_node.coords)
	if destination != null:
		var current_dist_vec = globals.diam_to_rect(destination) * globals.grid_size - position
		if current_dist_vec.length() < 3:
			# Eat the flower
			var obj_array = $"/root/Game/grass_test_slope".objects.get(coords)
			if obj_array != null:
				for obj in obj_array:
					if obj is Flower:
						obj_array.erase(obj)
						obj.queue_free()
				if obj_array.size() == 0:
					$"/root/Game/grass_test_slope".objects.erase(coords)
			# Get a new path
			next_path_node = path.pop_front()
			if next_path_node != null:
				set_destination(next_path_node.coords)
			else:
				set_destination(null)

func get_move_direction() -> void:
	pass
