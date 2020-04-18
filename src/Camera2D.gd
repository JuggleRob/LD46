extends Camera2D

var camera_speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
		
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		offset.x += camera_speed * delta
	if Input.is_action_pressed("ui_left"):
		offset.x -= camera_speed * delta
	if Input.is_action_pressed("ui_down"):
		offset.y += camera_speed * delta
	if Input.is_action_pressed("ui_up"):
		offset.y -= camera_speed * delta
