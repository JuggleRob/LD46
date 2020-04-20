extends TileMap

func _process(delta: float) -> void:
	Draw_Health()
	
func Draw_Health():
	for i in range($"/root/Game/Schaap/".max_stomach):
		set_cell(11 + i,2,0)	
	for i in range($"/root/Game/Schaap/".max_stomach - $"/root/Game/Schaap/".stomach):
		set_cell(11 + $"/root/Game/Schaap/".max_stomach - i - 1, 2, 1)
	return
