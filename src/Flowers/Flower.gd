extends Actor

class_name Flower

func _ready():
	pass

func set_random_frame():
	self.frame = randi() % self.frames.get_frame_count(self.animation)
