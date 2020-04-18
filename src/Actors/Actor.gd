extends Node2D

class_name Actor

export var speed = 256 # big number because it's multiplied by delta
var tile_size = 64 # size in pixels of tiles on the grid
var last_position = Vector2() # last idle position
var target_position = Vector2() # desired position to move towards
var movedir = Vector2() # move direction	

# Gets called every frame
func _process(delta: float) -> void:
	# MOVEMENT
	position += speed * movedir * delta
	
	# if we've moved further than one space
	if position.distance_to(last_position) >= tile_size:
		position = target_position
