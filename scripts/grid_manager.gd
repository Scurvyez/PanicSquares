extends Node2D # grid_manager.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var PLAYER = get_node("/root/Game/player")

var colorUpperGridBar = Color8(0, 0, 0, 255)
var colorGridlinesPrimary = Color8(0, 0, 0, 100) # main grid color
var colorGridlinesSecondary = Color8(0, 0, 0, 35) # aux gridlines color
var colorPlayerDebugCell = Color8(255, 0, 0, 100) # color for the player's current cell

var allCells = [] # array of all cells in the grid
var allCellsUnoccupied = [] # array of unoccupied cells
var allCellsOccupied = {} # dictionary of occupied cells

func _ready():
	initialize_all_cells()
	initialize_spawnable_cells()

func _process(_delta):
	queue_redraw()

func initialize_all_cells():
	allCells.clear()
	for x in range(GLOBALS.gridSize.x):
		for y in range(GLOBALS.gridSize.y):
			allCells.append(Vector2(x, y))

func initialize_spawnable_cells():
	allCellsUnoccupied.clear()
	for x in range(GLOBALS.gridSize.x):
		for y in range(1, GLOBALS.gridSize.y): # Start from y = 1 to exclude the top row
			allCellsUnoccupied.append(Vector2(x, y))

func is_cell_occupied(cell):
	return allCellsOccupied.has(cell)

func get_random_cell_position():
	if allCellsUnoccupied.size() == 0:
		print("No spawnable cells available.")
		return Vector2.ZERO

	# Find a random unoccupied cell
	var cell = Vector2.ZERO
	var tries = 0
	while tries < 100:
		var rand_index = randi() % allCellsUnoccupied.size()
		cell = allCellsUnoccupied[rand_index]
		if not is_cell_occupied(cell):
			break
		tries += 1

	if is_cell_occupied(cell):
		print("Couldn't find an unoccupied cell.")
		return Vector2.ZERO

	var cell_pos = cell * GLOBALS.cellSize + GLOBALS.cellSize / 2
	return cell_pos

func mark_cell_occupied(cell):
	allCellsOccupied[cell] = true

func mark_cell_unoccupied(cell):
	allCellsOccupied.erase(cell)

func _draw():
	if GLOBALS.drawGrid:
		# Draw the main grid
		for x in range(GLOBALS.gridSize.x):
			for y in range(1, GLOBALS.gridSize.y): # Start from y = 1 to exclude the top row
				var cell_pos = Vector2(x, y) * GLOBALS.cellSize
				draw_rect(Rect2(cell_pos, GLOBALS.cellSize), colorGridlinesPrimary, false)

		var top_horiz_line = (GLOBALS.screenSize.y / GLOBALS.gridSize.y) # line y position on grid
		draw_line(Vector2(0, top_horiz_line), Vector2(GLOBALS.screenSize.x, top_horiz_line), colorUpperGridBar, 4)

		# Draw vertical center lines
		for x in range(GLOBALS.gridSize.x):
			var line_x = x * GLOBALS.cellSize.x + GLOBALS.cellSize.x / 2
			draw_line(Vector2(line_x, GLOBALS.cellSize.y), Vector2(line_x, GLOBALS.screenSize.y), colorGridlinesSecondary, 1) # Start from the second row

		# Draw horizontal center lines
		for y in range(1, GLOBALS.gridSize.y): # Start from y = 1 to exclude the top row
			var line_y = y * GLOBALS.cellSize.y + GLOBALS.cellSize.y / 2
			draw_line(Vector2(0, line_y), Vector2(GLOBALS.screenSize.x, line_y), colorGridlinesSecondary, 1)
		
	if GLOBALS.DEBUGGING_Active:
		# Color cell the player is currently in
		var cell_rect = Rect2(GLOBALS.playerCell * GLOBALS.cellSize, GLOBALS.cellSize)
		draw_rect(cell_rect, colorPlayerDebugCell, true)
