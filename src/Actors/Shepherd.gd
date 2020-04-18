# movement functionality from https://fornclake.com/2019/03/grid/
extends Actor

# GET DIRECTION THE PLAYER WANTS TO MOVE
func get_move_direction() -> void:
	var LEFT = Input.is_action_pressed("move_left")
	var RIGHT = Input.is_action_pressed("move_right")
	var UP = Input.is_action_pressed("move_up")
	var DOWN = Input.is_action_pressed("move_down")
	
	# if pressing both directions this will return 0
	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)

	# prevent diagonals
	if movedir.x != 0 && movedir.y != 0:
		movedir = Vector2.ZERO

# this _process as well as the _proces on top of the parents' _process
func _process(delta: float) -> void:
	# IDLE
	if position == target_position: # only move if shepherd is in the middle of the tile
		get_move_direction()
		last_position = position # record the player's current idle position
		target_position += movedir * tile_size # if key is pressed, get new target (also shifts to moving state)

