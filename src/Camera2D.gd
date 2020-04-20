extends Camera2D

var camera_speed = 100
var camera_speed_pro_mega_better = 0.7

func _ready():
	offset.x  =  $"/root/Game/Schaap".position.x
	offset.y  =  $"/root/Game/Schaap".position.y

func _process(delta):
#	if Input.is_action_pressed("ui_right"):
#		offset.x += camera_speed * delta
#	if Input.is_action_pressed("ui_left"):
#		offset.x -= camera_speed * delta
#	if Input.is_action_pressed("ui_down"):
#		offset.y += camera_speed * delta
#	if Input.is_action_pressed("ui_up"):
	#		offset.y -= camera_speed * delta
	
	if $"/root/Game/Schaap".position.x > offset.x:
		offset.x += camera_speed_pro_mega_better
	if $"/root/Game/Schaap".position.x < offset.x:
		offset.x -= camera_speed_pro_mega_better
	if $"/root/Game/Schaap".position.y > offset.y:
		offset.y += camera_speed_pro_mega_better
	if $"/root/Game/Schaap".position.y < offset.y:
		offset.y -= camera_speed_pro_mega_better

	#offset.x  =  $"/root/Game/Schaap".position.x
	#offset.y  =  $"/root/Game/Schaap".position.y
