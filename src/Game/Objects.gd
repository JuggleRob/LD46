extends Node2D


var objects = {} # dictionary of coordinates to objects such as flowers

func add_object(coords, obj):
	add_child(obj)
	obj.set_coords(coords)
	if objects.get(coords) == null:
		objects[coords] = []
		objects[coords].append(obj)

func eat_at_coords(coords, eater):
	print("eating at " + str(coords))
	var obj_array = objects.get(coords)
	if obj_array != null:
		print(obj_array)
		for obj in obj_array:
			if obj is Flower:
				if obj.animation == "flower_good":
					eater.eat_countdown = eater.eat_duration
				elif obj.animation == "flower_bad":
					eater.stomach = max(0, eater.stomach - 40)
					eater.emit_signal("update_stomach", eater.stomach)
					if eater.stomach <= 0:
						eater.die()
				obj_array.erase(obj)
				obj.queue_free()
		if obj_array.size() == 0:
			objects.erase(coords)
