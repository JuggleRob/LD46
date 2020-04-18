# movement functionality from https://fornclake.com/2019/03/grid/
extends Node2D

class_name Actor

export var speed = 25
var move_dir = Vector2() # move direction	

# Gets called every frame
func _process(delta: float) -> void:
	position += speed * move_dir * delta
