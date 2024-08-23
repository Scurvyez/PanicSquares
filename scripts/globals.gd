extends Node # globals.gd script

# DEBUGGING
var DEBUGGING_Active = false

# screen
var screenSize # the size as a Vector2 (in pixels) of the entire playable screen
var gridSize = Vector2(12, 7) # grid size (rows, columns) for grid system 12 * 7 = base (84 cells)
var cellSize # the size as a Vector2 (in pixels) of a single cell within our grid
var drawGrid = true

# player
var playerMaxHearts = 5 # maximum number of hearts
var playerHearts = 5 # player's max (starting) hearts
var playerCell # player position as a whole cell
var playerSpeed = 1000.0 # maximum speed
var playerAccel = 2000.0 # acceleration
var playerDecel = 750.0 # deceleration
var playerRotationSpeed = 10.0 # rotation speed
var playerIsGhost = false # should the player behave like a ghost or not?

# enemy
var enemyCell # player position as a whole cell
var enemySpeed = 50.0 # maximum speed
var enemyChaseSpeed = 150.0 # speed of enemies while chasing the player
var enemyRotationSpeed = 10.0 # rotation speed
var enemyDetectRadius = 200.0 # enemy detection radius
var enemySpawnScoreThreshold = 150 # score at which we start spawning enemies
var enemySpawnChance = 0.05 # chance to spawn an enemy, every time

# collectibles
var collectibleTimeBoosterChance = 0.075 # time booster chance
var collectibleRotationSpeed = 360.0 # rotation speed per second

# heart pickups
var heartSpawnChance = 0.075 # heart spawn chance
var heartRotationSpeed = 180.0 # rotation speed per second
var heartSpawnScoreThreshold = 150 # score at which we start spawning life pickups
var lifePickupIsActive = false # is there a heart currently spawned? only one at a time

# ghost physics power-ups
var ghostPhysicsPowerupSpawnChance = 0.05
var ghostPhysicsPowerupRotationSpeed = 720.0 # rotation speed per second
var ghostPhysicsPowerupSpawnScoreThreshold = 125
var ghostPhysicsPowerupLifetime = 10.0 # (seconds)
var ghostPhysicsTimer = null
var ghostPhysicsPowerUpIsActive = false # is there a ghost physics power-up currently spawned? only one at a time

# walls
var wallFallbackScale = Vector2(4, 4) # fallback scale size 
var wallLerpScaleChance = 0.25 # chance for wall to oscillate scale
var wallLerpScaleSpeed = 0.25 # Speed of the oscillation
var wallPassableChance = 0.25 # chance for wall to be passable

func _ready():
	screenSize = get_parent().get_viewport_rect().size
	cellSize = screenSize / gridSize
