extends Node2D

var globals

func _ready():
	globals = get_node("/root/Globals")
	position.y += globals.tile_size.y / 2
	generate_patch(Vector2(0, 0))

func generate_patch(patch_offset):
	for col in range(globals.rows):
		for row in range(globals.rows):
			$"0".set_cell(row, col, 9)

func bfs(start: Vector2,e):	
	# combine neighbour_x and neighbour_y to get the coordinates for a possible neighbour
	var neighbour_x = [-1,1,0,0]
	var neighbour_y = [0,0,+1,-1] 
	
	var visited = []
	for row in range(globals.rows):
		#visited.append([])
		visited[row] = []
		for col in range(globals.rows):
			visited[row][col] = false

	# x and y coordinates of nodes that are in the queue
	var queue_row = [start.x]
	var queue_col = [start.y]

	visited[start.x][start.y] = true

	while queue_row.size() > 0:
		var row = queue_row.pop_front()
		var col = queue_col.pop_front()
		if $"0".get_cell(row,col) == 7 : # 7 is een placeholder voor de waarde die de bloem gaat hebben
			# bloem gevonden, return pad
			break
			
		# Explore neighbours
		for i in range(4):
			var neighbour_row = row + neighbour_x[i]
			var neighbour_col = col + neighbour_y[i]
			
			# skip out of bound locations
			if neighbour_row < 0 or neighbour_col < 0: continue
			if neighbour_row >= globals.rows or neighbour_col >= globals.col: continue
			
			# skip visited locations or impossible tiles
			if visited[neighbour_row][neighbour_col]: continue
			# if impossible tile: continue
			
			queue_row.push_back(neighbour_row)
			queue_col.push_back(neighbour_col)
			visited[neighbour_row][neighbour_col] = true
		
		return
