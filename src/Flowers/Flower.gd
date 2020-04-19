extends AnimatedSprite

class_name Flower

var coords

func set_coords(coords):
	self.coords = coords
	position = Globals.diam_to_rect(coords) * Globals.grid_size
