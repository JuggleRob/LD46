extends Control

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	anim_player.play("drop")
	$score.text = "Distance covered: " + str(Globals.distance_covered)
