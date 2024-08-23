extends Node2D # game.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var GAME_MANAGER = get_node("/root/Game/game_manager")
@onready var GRID_MANAGER = get_node("/root/Game/grid_manager")
@onready var SPAWNING_UTIL = get_node("/root/Game/spawning_util")
@onready var SFX_COLLECTIBLE_PICKUP = get_node("/root/Game/sfx/collectible_pickup")
@onready var SFX_GHOST_PHYSICS_POWERUP = get_node("/root/Game/sfx/ghost_physics_powerup")
@onready var SFX_WALL_SPAWN = get_node("/root/Game/sfx/wall_spawn")
@onready var PLAYER = get_node("/root/Game/player")

var scenePlayer = preload("res://scenes/player.tscn")
var sceneCollectible = preload("res://scenes/collectible.tscn")
var sceneLifePickup = preload("res://scenes/life_pickup.tscn")
var sceneWall = preload("res://scenes/wall.tscn")
var sceneEnemy = preload("res://scenes/enemy.tscn")
var sceneGhostPhysicsPowerup = preload("res://scenes/powerup_ghost_physics.tscn")

var numAvailCellsForSpawning  # maximum number of cells for spawning things
var numMaxWallsAllowed  # maximum number of walls allowed at once
var fallbackPosition = Vector2.ZERO  # fallback position in screen space

var collectibleInstances = [] # array to keep track of collectible instances
var collectiblePositions = [] # array to keep track of collectible positions
var wallInstances = [] # array to keep track of wall instances
var wallPositions = [] # array to keep track of wall positions
var ghostPhysicsPowerUpInstances = [] # 
var ghostPhysicsPowerUpPositions = [] # 

var colorHeartSpriteBase = Color8(255, 102, 102, 255) # base color
var heartSprites = [] # array to keep track of heart sprites
var numMaxHearts # number of heart sprites to have (max)

var heartOscillationSpeed = 2.0
var heartOscillationAmplitude = 10.0
var heartAnimationTimeElapsed = 0.0

func _ready():
	# Instantiate and position the player
	var inst_player = scenePlayer.instantiate()
	inst_player.position = GLOBALS.screenSize / 2
	add_child(inst_player)
	
	numMaxHearts = GLOBALS.playerHearts
	update_health_sprites()
	
	if GRID_MANAGER != null:
		numAvailCellsForSpawning = GRID_MANAGER.allCellsUnoccupied
		numMaxWallsAllowed = (numAvailCellsForSpawning.size() / 2) - GLOBALS.gridSize.x
	
	GAME_MANAGER.connect("score_factor_of_10", Callable(self, "_on_score_factor_of_10"))
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("player_touched_enemy", Callable(self, "_on_player_touched_enemy"))
	
	for life_pickup in get_tree().get_nodes_in_group("life_pickups"):
		life_pickup.connect("life_pickup_collected", Callable(self, "_on_life_pickup_collected"))
	
	for ghost_physics_powerup in get_tree().get_nodes_in_group("powerups"):
		ghost_physics_powerup.connect("ghost_physics_powerup_collected", Callable(self, "_on_ghost_physics_powerup_collected"))
		#ghost_physics_powerup.connect("timeout_ghost_physics_timer", Callable(self, "_on_timeout_ghost_physics_timer"))
	
	spawn_collectible()

func _process(delta):
	heartAnimationTimeElapsed += delta
	
	print("Powerup active: " + str(GLOBALS.ghostPhysicsPowerUpIsActive))
	print("Player is a ghost: " + str(GLOBALS.playerIsGhost))
	
	for i in range(heartSprites.size()):
		var sprite = heartSprites[i]
		var initial_y = (GLOBALS.screenSize.y / GLOBALS.gridSize.y) * 0.5
		sprite.position.y = initial_y + sin(heartAnimationTimeElapsed * heartOscillationSpeed + i) * heartOscillationAmplitude

func update_health_sprites():
	for i in range(heartSprites.size()):
		var sprite = heartSprites[i]
		remove_child(sprite)
		sprite.queue_free()
	
	heartSprites.clear()

	var initial_x = GLOBALS.screenSize.x - 20
	var initial_y = (GLOBALS.screenSize.y / GLOBALS.gridSize.y) * 0.5
	var pos_offset = 40
	
	for i in range(GLOBALS.playerHearts):
		var player_heart = Sprite2D.new()
		player_heart.texture = load("res://textures/player_heart.png")
		player_heart.position = Vector2(initial_x - i * pos_offset, initial_y)
		player_heart.modulate = colorHeartSpriteBase
		player_heart.scale = Vector2(2, 2)
		player_heart.z_index = 1
		add_child(player_heart)
		heartSprites.insert(0, player_heart)

func spawn_collectible():
	var inst_collec = sceneCollectible.instantiate()
	var cell_pos = SPAWNING_UTIL.get_valid_collectible_spawn_position()
	
	if cell_pos == fallbackPosition:
		return
	
	inst_collec.position = cell_pos
	GRID_MANAGER.mark_cell_occupied(cell_pos / GLOBALS.cellSize)
	inst_collec.connect("collectible_collected", Callable(self, "_on_collectible_collected"))
	inst_collec.connect("spawn_enemy", Callable(self, "_on_spawn_enemy"))
	inst_collec.connect("spawn_life_pickup", Callable(self, "_on_spawn_life_pickup"))
	inst_collec.connect("spawn_ghost_physics_powerup", Callable(self, "_on_spawn_ghost_physics_powerup"))
	inst_collec.connect("collectible_timed_out", Callable(self, "_on_collectible_timed_out"))
	add_child(inst_collec)
	collectibleInstances.append(inst_collec)
	collectiblePositions.append(cell_pos / GLOBALS.cellSize)

func spawn_wall():
	var inst_wall = sceneWall.instantiate()
	var cell_pos = SPAWNING_UTIL.get_valid_wall_spawn_position()
	
	if cell_pos == fallbackPosition:
		return
	
	inst_wall.position = cell_pos
	GRID_MANAGER.mark_cell_occupied(cell_pos / GLOBALS.cellSize)
	inst_wall.connect("wall_disappeared", Callable(self, "_wall_disappeared"))
	add_child(inst_wall)
	wallInstances.append(inst_wall)
	wallPositions.append(cell_pos / GLOBALS.cellSize)
	
	SFX_WALL_SPAWN.pitch_scale = randf_range(0.8, 1.2)
	SFX_WALL_SPAWN.play()

func spawn_enemy():
	var inst_enemy = sceneEnemy.instantiate()
	var cell_pos = SPAWNING_UTIL.get_valid_enemy_spawn_position()
	
	if cell_pos == fallbackPosition:
		return
	
	add_child(inst_enemy)
	inst_enemy.position = cell_pos
	inst_enemy.add_to_group("enemies")
	inst_enemy.connect("player_touched_enemy", Callable(self, "_on_player_touched_enemy"))

func spawn_life_pickup():
	GLOBALS.lifePickupIsActive = true
	var inst_life_pickup = sceneLifePickup.instantiate()
	var cell_pos = SPAWNING_UTIL.get_valid_life_pickup_spawn_position()
	
	if cell_pos == fallbackPosition:
		GLOBALS.lifePickupIsActive = false
		return
	
	inst_life_pickup.position = cell_pos
	GRID_MANAGER.mark_cell_occupied(cell_pos / GLOBALS.cellSize)
	inst_life_pickup.add_to_group("life_pickups")
	inst_life_pickup.connect("life_pickup_collected", Callable(self, "_on_life_pickup_collected"))
	add_child(inst_life_pickup)
	collectibleInstances.append(inst_life_pickup)
	collectiblePositions.append(cell_pos / GLOBALS.cellSize)

func spawn_ghost_physics_powerup():
	GLOBALS.ghostPhysicsPowerUpIsActive = true
	var inst_powerup = sceneGhostPhysicsPowerup.instantiate()
	var cell_pos = SPAWNING_UTIL.get_valid_collectible_spawn_position()
	
	if cell_pos == fallbackPosition:
		GLOBALS.ghostPhysicsPowerUpIsActive = false
		return
	
	inst_powerup.position = cell_pos
	inst_powerup.add_to_group("powerups")
	inst_powerup.connect("ghost_physics_powerup_collected", Callable(self, "_on_ghost_physics_powerup_collected"))
	#inst_powerup.connect("timeout_ghost_physics_timer", Callable(self, "_on_timeout_ghost_physics_timer"))
	add_child(inst_powerup)
	ghostPhysicsPowerUpInstances.append(inst_powerup)
	ghostPhysicsPowerUpPositions.append(cell_pos / GLOBALS.cellSize)

func _on_spawn_enemy():
	spawn_enemy()

func _on_spawn_life_pickup():
	spawn_life_pickup()

func _on_spawn_ghost_physics_powerup():
	spawn_ghost_physics_powerup()

func _on_player_touched_enemy():
	GLOBALS.playerHearts -= 1
	update_health_sprites()

func _on_collectible_collected(collectible):
	SFX_COLLECTIBLE_PICKUP.pitch_scale = randf_range(0.7, 1.3)
	SFX_COLLECTIBLE_PICKUP.play()
	var cell_key = collectible.position / GLOBALS.cellSize
	GRID_MANAGER.mark_cell_unoccupied(cell_key)
	collectibleInstances.erase(collectible)
	collectiblePositions.erase(cell_key)
	call_deferred("spawn_collectible")

func _on_life_pickup_collected(life_pickup):
	SFX_COLLECTIBLE_PICKUP.pitch_scale = randf_range(1.3, 1.6)
	SFX_COLLECTIBLE_PICKUP.play()
	var cell_key = life_pickup.position / GLOBALS.cellSize
	GRID_MANAGER.mark_cell_unoccupied(cell_key)
	collectibleInstances.erase(life_pickup)
	collectiblePositions.erase(cell_key)
	
	GLOBALS.playerHearts += 1
	update_health_sprites()
	GLOBALS.lifePickupIsActive = false

func _on_ghost_physics_powerup_collected(ghost_physics_powerup):
	SFX_GHOST_PHYSICS_POWERUP.pitch_scale = randf_range(1.0, 1.1)
	SFX_GHOST_PHYSICS_POWERUP.play()
	var cell_key = ghost_physics_powerup.position / GLOBALS.cellSize
	GRID_MANAGER.mark_cell_unoccupied(cell_key)
	ghostPhysicsPowerUpInstances.erase(ghost_physics_powerup)
	ghostPhysicsPowerUpPositions.erase(cell_key)
	GLOBALS.ghostPhysicsPowerUpIsActive = false
	
	GLOBALS.ghostPhysicsTimer = Timer.new()
	GLOBALS.ghostPhysicsTimer.wait_time = GLOBALS.ghostPhysicsPowerupLifetime
	GLOBALS.ghostPhysicsTimer.one_shot = true
	GLOBALS.ghostPhysicsTimer.connect("timeout", Callable(self, "_on_timeout_ghost_physics_timer"))
	add_child(GLOBALS.ghostPhysicsTimer)
	GLOBALS.ghostPhysicsTimer.start()

func _wall_disappeared(wall):
	SFX_WALL_SPAWN.pitch_scale = randf_range(0.8, 1.2)
	SFX_WALL_SPAWN.play()
	var cell_key = wall.position / GLOBALS.cellSize
	GRID_MANAGER.mark_cell_unoccupied(cell_key)
	wallInstances.erase(wall)
	wallPositions.erase(cell_key)
	call_deferred("spawn_wall")

func _on_score_factor_of_10(_score):
	if wallInstances.size() < numMaxWallsAllowed:
		call_deferred("spawn_wall")

func _on_collectible_timed_out(collectible):
	var cell_key = collectible.position / GLOBALS.cellSize
	GRID_MANAGER.mark_cell_unoccupied(cell_key)
	collectibleInstances.erase(collectible)
	collectiblePositions.erase(cell_key)
	call_deferred("spawn_collectible")

func _on_timeout_ghost_physics_timer():
	GLOBALS.playerIsGhost = false
