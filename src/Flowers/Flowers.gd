extends Node2D

var Flower = preload("res://src/Flowers/Flower.tscn")
var globals

# Called when the node enters the scene tree for the first time.
func _ready():
	globals = get_node("/root/Globals")

func add_flower(gridpos):
	var flower = Flower.instance()
	flower.position = gridpos * globals.tile_size
	add_child(flower)
