extends Actor

signal update_stomach
signal show_game_over

var path
export var max_stomach = 15
export var stomach = 15
export var hunger_rate = 1
export var eat_rate = 3
export var poison_rate = 1
var eat_countdown = 0
var eat_duration = 1
var move_dir
var face_dir
var sight = 4
var objects
var base_sprite_position
var flip_offset = Vector2(-21, 0)

func _ready():
	connect("update_stomach", $"/root/Game/UI/Stomach", "update_stomach")
	face_dir = Vector2(0, 1)
	set_move_dir(Vector2(0, 0))
	objects = $"/root/Game/Objects"
	base_sprite_position = Vector2(10, -6)
	$AnimationPlayer/sprite.position = base_sprite_position
	Globals.paused = true

func set_move_dir(move_vector_diam):
	move_dir = move_vector_diam
	if move_dir != Vector2(0, 0):
		face_dir = move_dir
	var move_vector_rect = Globals.diam_to_rect(move_vector_diam)
	if move_vector_rect == Vector2(0, 0):
		if Globals.diam_to_rect(face_dir).y < 0:
			$AnimationPlayer/sprite.set_animation("idle_ne")
		else:
			$AnimationPlayer/sprite.set_animation("idle")
	else:
		if move_vector_rect.y >= 0:
			$AnimationPlayer/sprite.set_animation("jump_se")
		elif move_vector_rect.y < 0:
			$AnimationPlayer/sprite.set_animation("jump_ne")
		if move_vector_rect.x  >= 0:
			$AnimationPlayer/sprite.position = base_sprite_position
			$AnimationPlayer/sprite.flip_h = false
		elif move_vector_rect.x < 0:
			$AnimationPlayer/sprite.position = base_sprite_position + flip_offset
			$AnimationPlayer/sprite.flip_h = true

func set_coords(coords, level = 0):
	.set_coords(coords)
	$AnimationPlayer/sprite.set_offset(self.position)

func idle_ends():
	if Globals.paused:
		return
	if Globals.game_over:
		$AnimationPlayer/sprite.set_animation("death")
		return
	self.set_coords(self.diam_coords + self.move_dir)
	# Die if in water
	var maybe_water = $"/root/Game/Map".get_tile(self.diam_coords)
	if $"/root/Game/Map".is_water(maybe_water):
		die()
		return
	# Eat flowers, if any
	var eaten = objects.eat_at_coords(self.diam_coords, self)
	# Idle for a turn
	if eaten:
		set_move_dir(Vector2(0, 0))
		return
	# Done idling, decide next jump!
	move_dir = face_dir
	var left_dir = move_dir.rotated(-0.5 * PI)
	left_dir = Vector2(round(left_dir.x), round(left_dir.y))
	var right_dir = move_dir.rotated(0.5 * PI)
	right_dir = Vector2(round(right_dir.x), round(right_dir.y))
	var dirs
	if randf() > 0.5:
		dirs = [move_dir, left_dir, right_dir]
	else:
		dirs = [move_dir, right_dir, left_dir]
	var flower_found = false
	# height level of the farthest levels in directions (like dirs)
	var lvls = [current_level, current_level, current_level]
	# hold dirs that are unreachable
	var dead_ends = []
	for dist in range(1, sight):
		for dir_idx in dirs.size():
			var dir = dirs[dir_idx]
			if not dir in dead_ends:
				var next_coords = self.diam_coords + dist * dir
				if not $"/root/Game/Map".reachable( \
						self.diam_coords + (dist - 1) * dir, \
						next_coords):
					dead_ends.append(dir)
					continue
				# reachable! set new height level in this direction
				lvls[dir_idx] = $"/root/Game/Map".top_level(next_coords)
				var objs = objects.get_objects(next_coords)
				if objs != null:
					for obj in objs:
						if obj is Flower:
							set_move_dir(dir)
							flower_found = true
							break
				if flower_found: break
		if flower_found: break
	if not flower_found:
		var backtrack = true
		for dir in dirs:
			if $"/root/Game/Map".reachable( \
					self.diam_coords,
					self.diam_coords + dir):
				set_move_dir(dir)
				backtrack = false
				break
		if backtrack:
			set_move_dir(-move_dir)
		
# finds a next jump and keeps sprite accurate
func jump_ends():
	Globals.distance_covered += 1
	Globals.difficulty = Globals.difficulty + 0.01 * (0.7 - Globals.difficulty)
	$AnimationPlayer/sprite.speed_scale = 2 + Globals.difficulty
	print(Globals.difficulty)
	stomach -= 1
	$"/root/Game/UI/steps".text = "Steps: " + str(Globals.distance_covered)
	if Globals.game_over:
		return
	$"/root/Game/Map".maybe_spawn_flowers()
	idle_ends()
	#stomach = max(0, stomach - hunger_rate)
	emit_signal("update_stomach", stomach)
	if stomach <= 0:
		die()
	if diam_coords == Vector2(3,-10):
		print("BRUG")

func die():
	path = null
	set_move_dir(Vector2(0, 0))
	Globals.game_over = true
	$AnimationPlayer/sprite.set_animation("death")
	$"/root/Game/Audio/death".play()

func _input(event):
	if event.is_action_pressed("ui_accept") and Globals.paused:
		Globals.paused = false
		set_move_dir(Vector2(0, 1))
#	if even.is_action_pressed("fullscreen"):
#		$"/root/Game/Camera2D"

func _on_sprite_animation_finished():
	var anim = $AnimationPlayer/sprite.animation
	if anim == "idle" or anim == "idle_ne":
		idle_ends()
	elif anim == "jump_se" or anim == "jump_ne":
		jump_ends()
	elif anim == "death":
		emit_signal("show_game_over")
		
