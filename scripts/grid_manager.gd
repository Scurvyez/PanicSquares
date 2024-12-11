extends Node2D # grid_manager.gd script

@onready var Globals = get_node("/root/Game/globals")

var col_up_gb = Color8(0, 0, 0, 255) # upper grid bar
var col_GlP = Color8(0, 0, 0, 100) # main grid
var col_GlS = Color8(0, 0, 0, 35) # aux gridlines
var col_PlDc = Color8(255, 0, 0, 100) # player's current cell

var allcells = [] # array of all cells in the grid
var allcells_uo = [] # array of unoccupied cells
var allcells_o = {} # dictionary of occupied cells

func _ready():
	initialize_all_cells()
	initialize_spawnable_cells()


func _process(_delta):
	queue_redraw()


func initialize_all_cells():
	allcells.clear()
	for x in range(Globals.gridSize.x):
		for y in range(Globals.gridSize.y):
			allcells.append(Vector2(x, y))


func initialize_spawnable_cells():
	allcells_uo.clear()
	for x in range(Globals.gridSize.x):
		# Start from y = 1 to exclude the top row
		for y in range(1, Globals.gridSize.y):
			allcells_uo.append(Vector2(x, y))


func is_cell_occupied(cell):
	return allcells_o.has(cell)


func get_random_cell_position():
	if allcells_uo.size() == 0:
		print("No spawnable cells available.")
		return Vector2.ZERO

	# Find a random unoccupied cell
	var cell = Vector2.ZERO
	var tries = 0
	while tries < 100:
		var rand_index = randi() % allcells_uo.size()
		cell = allcells_uo[rand_index]
		if not is_cell_occupied(cell):
			break
		tries += 1

	if is_cell_occupied(cell):
		print("Couldn't find an unoccupied cell.")
		return Vector2.ZERO

	var cell_pos = cell * Globals.cellSize + Globals.cellSize / 2
	return cell_pos


func mark_cell_occupied(cell):
	allcells_o[cell] = true


func mark_cell_unoccupied(cell):
	allcells_o.erase(cell)


func _draw():
	if Globals.drawGrid:
		# Draw the main grid
		for x in range(Globals.gridSize.x):
			# Start from y = 1 to exclude the top row
			for y in range(1, Globals.gridSize.y):
				var cell_pos = Vector2(x, y) * Globals.cellSize
				draw_rect(Rect2(cell_pos, Globals.cellSize), col_GlP, false)
		
		# line y position on grid
		var top_horiz_line = (Globals.screenSize.y / Globals.gridSize.y)
		draw_line(Vector2(0, top_horiz_line), Vector2(Globals.screenSize.x, top_horiz_line), col_up_gb, 4)

		# Draw vertical center lines
		for x in range(Globals.gridSize.x):
			var line_x = x * Globals.cellSize.x + Globals.cellSize.x / 2
			# Start from the second row
			draw_line(Vector2(line_x, Globals.cellSize.y), Vector2(line_x, Globals.screenSize.y), col_GlS, 1)

		# Draw horizontal center lines
		# Start from y = 1 to exclude the top row
		for y in range(1, Globals.gridSize.y):
			var line_y = y * Globals.cellSize.y + Globals.cellSize.y / 2
			draw_line(Vector2(0, line_y), Vector2(Globals.screenSize.x, line_y), col_GlS, 1)
		
	if Globals.DEBUGGING_Active:
		# Color cell the player is currently in
		var cell_rect = Rect2(Globals.playerCell * Globals.cellSize, Globals.cellSize)
		draw_rect(cell_rect, col_PlDc, true)

