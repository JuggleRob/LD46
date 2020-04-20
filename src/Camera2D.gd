extends Camera2D

var camera_speed = 100
var move_factor = 3

func _ready():
	offset.x  =  $"/root/Game/Schaap".position.x
	offset.y  =  $"/root/Game/Schaap".position.y

func _process(delta):
	var sheep_pos = $"/root/Game/Schaap".position
	var dv = sheep_pos - offset
	offset += delta * move_factor * dv
