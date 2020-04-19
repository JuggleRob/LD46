# movement functionality from https://fornclake.com/2019/03/grid/
extends Node2D

class_name Actor

export var speed = 25
var move_dir = Vector2() # move direction	
var globals

func _ready():
	globals = get_node("/root/Globals")

func set_coords(coords):
	self.coords = coords
	position = globals.diam_to_rect(coords) * globals.grid_size

func after_move(delta):
	pass

# Gets called every frame
func _process(delta: float) -> void:
	position += speed * move_dir * delta
	self.after_move(delta)
