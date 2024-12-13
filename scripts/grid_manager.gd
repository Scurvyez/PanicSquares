extends Node2D

## --------------------------------/+\--------------------------------
## grid_manager.gd
## 
## This script controls everything related to our games' grid system.
##
## - Splits the screen into an even amount of cells
## - Each cell acts as a spawn point for various things
## - Draws lines to create the grid
## - Tracks all occupied / unoccupied cells for spawning
## --------------------------------\+/--------------------------------

@onready var ScreenManager = get_node("/root/Game/screen_manager")

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
	for x in range(ScreenManager.GridSize.x):
		for y in range(ScreenManager.GridSize.y):
			allcells.append(Vector2(x, y))


func initialize_spawnable_cells():
	allcells_uo.clear()
	for x in range(ScreenManager.GridSize.x):
		# Start from y = 1 to exclude the top row
		for y in range(1, ScreenManager.GridSize.y):
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

	var cell_pos = cell * ScreenManager.CellSize + ScreenManager.CellSize / 2
	return cell_pos


func mark_cell_occupied(cell):
	allcells_o[cell] = true


func mark_cell_unoccupied(cell):
	allcells_o.erase(cell)


func _draw():
	if ScreenManager.DrawGrid:
		# Draw the main grid
		for x in range(ScreenManager.GridSize.x):
			# Start from y = 1 to exclude the top row
			for y in range(1, ScreenManager.GridSize.y):
				var cell_pos = Vector2(x, y) * ScreenManager.CellSize
				draw_rect(
					Rect2(cell_pos, ScreenManager.CellSize), 
					col_GlP, 
					false
				)
		
		# line y position on grid
		var top_horiz_line = (
			ScreenManager.ScreenSize.y / ScreenManager.GridSize.y
		)
		draw_line(
			Vector2(0, top_horiz_line), 
			Vector2(ScreenManager.ScreenSize.x, top_horiz_line), 
			col_up_gb, 
			4
		)

		# Draw vertical center lines
		for x in range(ScreenManager.GridSize.x):
			var line_x = (
				x * ScreenManager.CellSize.x + ScreenManager.CellSize.x / 2
			)
			# Start from the second row
			draw_line(
				Vector2(line_x, ScreenManager.CellSize.y), 
				Vector2(line_x, ScreenManager.ScreenSize.y), 
				col_GlS, 
				1
			)

		# Draw horizontal center lines
		# Start from y = 1 to exclude the top row
		for y in range(1, ScreenManager.GridSize.y):
			var line_y = (
				y * ScreenManager.CellSize.y + ScreenManager.CellSize.y / 2
			)
			draw_line(
				Vector2(0, line_y), 
				Vector2(ScreenManager.ScreenSize.x, line_y), 
				col_GlS, 
				1
			)
		
	if Globals.DEBUGGING_Active:
		# Color cell the player is currently in
		var cell_rect = (
			Rect2(Globals.playerCell * ScreenManager.CellSize, ScreenManager.CellSize)
		)
		draw_rect(cell_rect, col_PlDc, true)

