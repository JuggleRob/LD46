extends Node2D


var objects = {} # dictionary of coordinates to objects such as flowers

func add_object(coords, obj):
	add_child(obj)
	obj.set_coords(coords)
	if objects.get(coords) == null:
		objects[coords] = []
		objects[coords].append(obj)

func remove_objects(coords):
	var obj_array = objects.get(coords)
	if obj_array != null:
		for obj in obj_array:
			obj_array.erase(obj)
			obj.queue_free()
		objects.erase(coords)

func remove_object(coords, obj):
	var obj_array = objects.get(coords)
	if obj_array != null:
		obj_array.erase(obj)
		if obj_array.size() == 0:
			objects.erase(coords)

func get_objects(coords):
	return objects.get(coords, null)

func eat_at_coords(coords, eater):
	var eaten
	var obj_array = objects.get(coords)
	if obj_array != null:
		for obj in obj_array:
			if obj is Flower:
				Globals.flowers_eaten += 1
				if obj.animation == "flower_good":
					$"/root/Game/Audio/flower_good".play()
					eater.stomach = min(eater.max_stomach, eater.stomach + eater.eat_rate)
				elif obj.animation == "flower_bad":
					$"/root/Game/Audio/flower_bad".play()
					eater.stomach = max(0, eater.stomach - eater.poison_rate)
					eater.emit_signal("update_stomach", eater.stomach)
					if eater.stomach <= 0:
						eater.die()
				obj_array.erase(obj)
				if obj == $"/root/Game/Map".flower_highlight:
					$"/root/Game/Map".flower_highlight = null
				obj.queue_free()
		if obj_array.size() == 0:
			objects.erase(coords)
		return true
	return false
