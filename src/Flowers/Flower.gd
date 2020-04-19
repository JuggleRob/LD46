extends Actor

class_name Flower

func set_random_frame():
	self.frame = randi() % self.frames.get_frame_count(self.animation)
