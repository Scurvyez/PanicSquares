extends CharacterBody2D # player.gd script

@onready var GAME = get_node("/root/Game")
@onready var GLOBALS = get_node("/root/Game/globals")
@onready var SPRITE_BASE = get_node("sprite_base")
@onready var SPRITE_TAIL = get_node("sprite_tail")
@onready var COLLISION_SHAPE_BASE = get_node("collision_shape_base")
@onready var COLLISION_SHAPE_TAIL = get_node("collision_shape_tail")

var spriteBaseColor = Color8(102, 255, 140, 255) # base color
var spriteGhostPhysicsColor = Color8(102, 255, 140, 100) # ghost physics color

func _ready():
	position = GLOBALS.screenSize / 2
	GLOBALS.playerCell = ((position - GLOBALS.cellSize / 2) / GLOBALS.cellSize).round()
	
	SPRITE_BASE.modulate = spriteBaseColor
	SPRITE_TAIL.modulate = spriteGhostPhysicsColor

func _physics_process(delta):
	var moveDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if moveDir != Vector2.ZERO:
		var targetVel = moveDir * GLOBALS.playerSpeed
		velocity = velocity.move_toward(targetVel, GLOBALS.playerAccel * delta)
		var targetRot = moveDir.angle()
		rotation = lerp_angle(rotation, targetRot, GLOBALS.playerRotationSpeed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, GLOBALS.playerDecel * delta)
	
	move_and_slide()
	screen_wrap()

func _process(_delta):
	# Update player's current cell position
	# "- GLOBALS.cellSize / 2" to offset the position by half in both x and y directions
	GLOBALS.playerCell = ((position - GLOBALS.cellSize / 2) / GLOBALS.cellSize).round()
	
	if GLOBALS.playerIsGhost:
		SPRITE_BASE.modulate = spriteGhostPhysicsColor
		SPRITE_TAIL.modulate = spriteGhostPhysicsColor
	else:
		SPRITE_BASE.modulate = spriteBaseColor
		SPRITE_TAIL.modulate = spriteBaseColor
	
func screen_wrap():
	var top_limit = GLOBALS.screenSize.y / GLOBALS.gridSize.y
	position.x = wrapf(position.x, 0, GLOBALS.screenSize.x)
	position.y = wrapf(position.y, top_limit, GLOBALS.screenSize.y)

func _on_draw():
	pass
