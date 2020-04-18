extends Actor

var destination

func _ready():
	pass

func set_destination(dest):
	self.destination = dest
	var move_vector = (self.position - self.destination)
	self.move_dir = move_vector.normalized()

func get_move_direction() -> void:
	pass
