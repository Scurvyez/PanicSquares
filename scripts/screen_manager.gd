extends Node # screen_manager.gd script

# screen
var ScreenSize # the size as a Vector2 (in pixels) of the entire playable screen
var GridSize = Vector2(12, 7) # grid size (rows, columns) for grid system 12 * 7 = base (84 cells)
var CellSize # the size as a Vector2 (in pixels) of a single cell within our grid
var DrawGrid = true


func _ready():
	ScreenSize = get_parent().get_viewport_rect().size
	CellSize = ScreenSize / GridSize

