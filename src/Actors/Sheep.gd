extends Actor

signal update_stomach

var coords
var destination # diamond coordinates of immediately next tile to move to
var path
var next_path_node
var stomach = 100
var hunger_rate = 4
var eat_rate = 30
var eat_countdown = 0
var eat_duration = 1

func _ready():
	connect("update_stomach", $"/root/Game/UI/Stomach", "update_stomach")

# set destination in diamond coordinates
func set_destination(dest):
	self.destination = dest
	if dest != null:
		var vec_diamond = self.destination - self.diam_coords
		move_dir = vec_diamond.normalized() 
		#(move_vector_rect * Globals.grid_size).normalized()
		var move_vector_rect = Globals.diam_to_rect(vec_diamond)
		if move_vector_rect.x  >= 0:
			self.scale.x = 1
		else:
			self.scale.x = -1 
	else:
		move_dir = Vector2()

func after_move(delta):
	$AnimationPlayer/sprite.offset = self.position
	if Globals.game_over:
		return
	if destination == null:
		var paths = $"/root/Game/Map".bfs(self.round_diam_coords)
		if paths.size() > 0:
			path = paths[0]
			var dest = path.back()
			next_path_node = path.pop_front()
			if next_path_node != null:
				set_destination(next_path_node.coords)
	if destination != null:
		var current_dist_vec = Globals.diam_to_rect(destination) * Globals.grid_size - position
		if current_dist_vec.length() < 3:
			# Eat the flower
			eat_at_coords(self.round_diam_coords)
			if path != null:
				# Got a new path
				next_path_node = path.pop_front()
				if next_path_node != null:
					set_destination(next_path_node.coords)
				else:
					set_destination(null)

func eat_at_coords(coords):
	var obj_array = $"/root/Game/Map".objects.get(coords)
	if obj_array != null:
		for obj in obj_array:
			if obj is Flower:
				if obj.animation == "flower_good":
					eat_countdown = eat_duration
				elif obj.animation == "flower_bad":
					stomach = max(0, stomach - 40)
					emit_signal("update_stomach", stomach)
					if stomach <= 0:
						die()
				obj_array.erase(obj)
				obj.queue_free()
		if obj_array.size() == 0:
			$"/root/Game/Map".objects.erase(coords)

func die():
	destination = null
	path = null
	next_path_node = null
	self.move_dir = Vector2(0, 0)
	Globals.game_over = true

func _process(delta):
	if not Globals.game_over:
		stomach = max(0, stomach - delta * hunger_rate)
		if eat_countdown > 0:
			eat_countdown = max(0, eat_countdown - delta)
			stomach = min(100, stomach + delta * eat_rate)
		emit_signal("update_stomach", stomach)
		if stomach <= 0:
			die()
