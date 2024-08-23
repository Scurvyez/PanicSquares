extends Node

@onready var GAME = get_node("/root/Game")
@onready var GLOBALS = get_node("/root/Game/globals")
@onready var GRID_MANAGER = get_node("/root/Game/grid_manager")
@onready var PLAYER = get_node("/root/Game/player")

var fallbackPosition = Vector2.ZERO  # fallback position in screen space

func get_valid_collectible_spawn_position():
	var cell_pos = fallbackPosition
	var tries = 0
	while tries < GAME.numAvailCellsForSpawning.size() * 2:
		cell_pos = GRID_MANAGER.get_random_cell_position()
		var cell_key = cell_pos / GLOBALS.cellSize
		if cell_pos == fallbackPosition or cell_key in GAME.wallPositions or cell_key in GAME.collectiblePositions:
			tries += 1
			continue
		break
	return cell_pos

func get_valid_life_pickup_spawn_position():
	var cell_pos = fallbackPosition
	var tries = 0
	while tries < GAME.numAvailCellsForSpawning.size() * 2:
		cell_pos = GRID_MANAGER.get_random_cell_position()
		var cell_key = cell_pos / GLOBALS.cellSize
		if cell_pos == fallbackPosition or cell_key in GAME.wallPositions or cell_key in GAME.collectiblePositions:
			tries += 1
			continue
		break
	return cell_pos

func get_valid_enemy_spawn_position():
	var cell_pos = fallbackPosition
	var tries = 0
	while tries < GAME.numAvailCellsForSpawning.size() * 2:
		cell_pos = GRID_MANAGER.get_random_cell_position()
		var cell_key = cell_pos / GLOBALS.cellSize
		if cell_pos == fallbackPosition or cell_key in GAME.collectiblePositions or cell_key in GAME.wallPositions or cell_pos == PLAYER.position or cell_pos == GLOBALS.playerCell:
			tries += 1
			continue
		break
	return cell_pos

func get_valid_wall_spawn_position():
	var cell_pos = fallbackPosition
	var tries = 0
	while tries < GAME.numAvailCellsForSpawning.size() * 2:
		cell_pos = GRID_MANAGER.get_random_cell_position()
		var cell_key = cell_pos / GLOBALS.cellSize
		if cell_pos == fallbackPosition or cell_key in GAME.collectiblePositions or cell_key in GAME.wallPositions or cell_pos == PLAYER.position or cell_pos == GLOBALS.playerCell:
			tries += 1
			continue
		break
	return cell_pos
