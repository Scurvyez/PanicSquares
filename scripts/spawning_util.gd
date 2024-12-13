extends Node

@onready var Game = get_node("/root/Game")
@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var GridManager = get_node("/root/Game/grid_manager")
@onready var Player = get_node("/root/Game/player")

var fb_pos = Vector2.ZERO # fallback position in screen space


func get_valid_collectible_spawn_position():
	var cell_pos = fb_pos
	var tries = 0
	while tries < Game.numAvailCellsForSpawning.size() * 2:
		cell_pos = GridManager.get_random_cell_position()
		var cell_key = cell_pos / ScreenManager.CellSize
		if (
				cell_pos == fb_pos 
				or cell_key in Game.wallPositions 
				or cell_key in Game.collectiblePositions
		):
			tries += 1
			continue
		break
	return cell_pos


func get_valid_life_pickup_spawn_position():
	var cell_pos = fb_pos
	var tries = 0
	while tries < Game.numAvailCellsForSpawning.size() * 2:
		cell_pos = GridManager.get_random_cell_position()
		var cell_key = cell_pos / ScreenManager.CellSize
		if (
				cell_pos == fb_pos 
				or cell_key in Game.wallPositions 
				or cell_key in Game.collectiblePositions
		):
			tries += 1
			continue
		break
	return cell_pos


func get_valid_enemy_spawn_position():
	var cell_pos = fb_pos
	var tries = 0
	while tries < Game.numAvailCellsForSpawning.size() * 2:
		cell_pos = GridManager.get_random_cell_position()
		var cell_key = cell_pos / ScreenManager.CellSize
		if (
				cell_pos == fb_pos 
				or cell_key in Game.collectiblePositions 
				or cell_key in Game.wallPositions 
				or cell_pos == Player.position 
				or cell_pos == Globals.playerCell
		):
			tries += 1
			continue
		break
	return cell_pos


func get_valid_wall_spawn_position():
	var cell_pos = fb_pos
	var tries = 0
	while tries < Game.numAvailCellsForSpawning.size() * 2:
		cell_pos = GridManager.get_random_cell_position()
		var cell_key = cell_pos / ScreenManager.CellSize
		if (
				cell_pos == fb_pos 
				or cell_key in Game.collectiblePositions 
				or cell_key in Game.wallPositions 
				or cell_pos == Player.position 
				or cell_pos == Globals.playerCell
		):
			tries += 1
			continue
		break
	return cell_pos

