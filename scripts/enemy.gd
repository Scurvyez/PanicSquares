extends CharacterBody2D # enemy.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var PLAYER = get_node("/root/Game/player")
@onready var SPRITE_BASE = get_node("sprite_base")
@onready var SPRITE_TAIL = get_node("sprite_tail")
@onready var AREA = get_node("area")

var spriteBaseColor = Color8(191, 191, 191, 125) # base color
var spriteTailColor = Color8(191, 191, 191, 125) # tail color

var lifeTime = randf_range(10.0, 45.0) # random lifetime between 10 and 45 seconds
var timerRandomDirection = 0.0 # timer for each movement change
var timer # timer for the enemy's lifetime

signal player_touched_enemy

func _ready():
	randomize()
	GLOBALS.enemyCell = ((position - GLOBALS.cellSize / 2) / GLOBALS.cellSize).round()
	
	SPRITE_BASE.modulate = spriteBaseColor
	SPRITE_TAIL.modulate = spriteTailColor
	
	# Set up the timer for lifetime
	timer = Timer.new()
	add_child(timer)
	set_lifetime()
	
	# Connect the signal for collision detection
	AREA.connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if PLAYER and PLAYER.position.distance_to(position) < GLOBALS.enemyDetectRadius:
		chase_player(delta)
	else:
		random_move(delta)

	# Apply movement
	move_and_slide()
	screen_wrap()
	
	# Update current enemy cell positions
	# make an array if we have > 1
	GLOBALS.enemyCell = ((position - GLOBALS.cellSize / 2) / GLOBALS.cellSize).round()

func _physics_process(_delta):
	# Set rotation to face the direction of movement or towards the player
	if PLAYER and PLAYER.position.distance_to(position) < GLOBALS.enemyDetectRadius:
		# Face the player
		rotation = (PLAYER.position - position).angle()
	else:
		# Face the direction of movement
		if velocity.length() > 0:
			rotation = velocity.angle()

func chase_player(_delta):
	var direction_to_player = (PLAYER.position - position).normalized()
	velocity = direction_to_player * GLOBALS.enemyChaseSpeed

func random_move(delta):
	timerRandomDirection -= delta
	if timerRandomDirection <= 0:
		# Change direction
		var angle = randf() * PI * 2
		velocity = Vector2(cos(angle), sin(angle)).normalized() * GLOBALS.enemySpeed
		# Set a new timer for direction change
		timerRandomDirection = randf_range(1.0, 3.0)

func screen_wrap():
	var top_limit = GLOBALS.screenSize.y / GLOBALS.gridSize.y
	position.x = wrapf(position.x, 0, GLOBALS.screenSize.x)
	position.y = wrapf(position.y, top_limit, GLOBALS.screenSize.y)

func set_lifetime():
	timer.wait_time = lifeTime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_lifetime_expired"))
	timer.start()

func _on_body_entered(body):
	if body.name == "player":
		emit_signal("player_touched_enemy")
		queue_free()

func _on_lifetime_expired():
	# When the lifetime timer expires, despawn the enemy
	queue_free()
