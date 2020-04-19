extends AnimatedSprite

class_name Flower

var coords
var globals

func _ready():
	globals = get_node("/root/Globals")

func set_coords(coords):
	self.coords = coords
	position = globals.diam_to_rect(coords) * globals.grid_size
