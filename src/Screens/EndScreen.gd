extends Control

onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	if Globals.distance_covered > Globals.highscore:
		Globals.highscore = Globals.distance_covered
	anim_player.play("drop")
	$score.text = "Distance covered: " + str(Globals.distance_covered)
	$highscore.text = "Highscore: " + str(Globals.highscore)
