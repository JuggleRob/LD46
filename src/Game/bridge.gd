extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

func show_bridge():
	$AudioStreamPlayer.play()
	self.visible = true
	$Timer.connect("timeout", self, "hide_bridge")
	$Timer.set_wait_time(5)
	$Timer.start()
	$"../AnimationPlayer".play("bridge_cross")
	
func hide_bridge():
	self.visible = false
