extends Actor

signal update_stomach

var destination # diamond coordinates of immediately next tile to move to
var path
var next_path_node
var stomach = 100
var hunger_rate = 4
var eat_rate = 30
var eat_countdown = 0
var eat_duration = 1
var move_dir
var sight = 4
var objects

func _ready():
	connect("update_stomach", $"/root/Game/UI/Stomach", "update_stomach")
	set_coords(Vector2(0, 0))
	set_move_dir(Vector2(0, 0))
	objects = $"/root/Game/Objects"

func set_move_dir(move_vector_diam):
	move_dir = move_vector_diam
	var move_vector_rect = Globals.diam_to_rect(move_vector_diam)
	if move_vector_rect == Vector2(0, 0):
		$AnimationPlayer/sprite.animation = "idle"
	else:
		if move_vector_rect.y >= 0:
			$AnimationPlayer/sprite.animation = "jump_se"
		elif move_vector_rect.y < 0:
			$AnimationPlayer/sprite.animation = "jump_ne"
		if move_vector_rect.x  >= 0:
			$AnimationPlayer/sprite.flip_h = false
		elif move_vector_rect.x < 0:
			$AnimationPlayer/sprite.flip_h = true

func set_coords(coords, level = 0):
	.set_coords(coords)
	$AnimationPlayer/sprite.offset = self.position

# finds a path, sets destination and keeps sprite accurate
func jump_ends():
	if Globals.game_over:
		return
	self.set_coords(self.diam_coords + self.move_dir)
	# Decide next jump
	var left_dir = move_dir.rotated(0.5 * PI)
	var right_dir = move_dir.rotated(-0.5 * PI)
	var dirs = [move_dir, left_dir, right_dir]
	var flower_found = false
	for dist in sight:
		for dir in dirs:
			var objs = objects.get_objects(self.diam_coords + dist * dir)
			if objs != null:
				for obj in objs:
					if obj is Flower:
						set_move_dir(dir)
						flower_found = true
						break
			if flower_found: break
		if flower_found: break
	# Eat flowers, if any
	objects.eat_at_coords(self.diam_coords, self)

func die():
	print("dying?")
	destination = null
	path = null
	next_path_node = null
	set_move_dir(Vector2(0, 0))
	Globals.game_over = true
	get_tree().change_scene("res://src/Screens/EndScreen.tscn")

func _process(delta):
	if not Globals.game_over:
		stomach = max(0, stomach - delta * hunger_rate)
		if eat_countdown > 0:
			eat_countdown = max(0, eat_countdown - delta)
			stomach = min(100, stomach + delta * eat_rate)
		emit_signal("update_stomach", stomach)
		if stomach <= 0:
			die()

func _on_sprite_animation_finished():
	jump_ends()
