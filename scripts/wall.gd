extends StaticBody2D # wall.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var SPRITE_BASE = get_node("sprite_base")
@onready var COLLISION_SHAPE_BASE = get_node("collision_shape_base")
@onready var LABEL_TIME_LEFT = get_node("DEBUG_time_left_label")

var colorSpriteBase = Color8(0, 0, 0, 255) # base color
var colorSpritePassable = Color8(191, 191, 191, 125) # passable color
var colorTimeLeftLabel = Color8(166, 166, 166, 255) # time left label color
var colorTimeLeftPassableLable = Color8(242, 242, 242, 255) # time left passable label color

var lifeTime = randf_range(10, 99) # (seconds before the wall disappears)
var scaleOriginal # original wall scale
var lerpScale = false # oscillate walls' scale or not
var passable = false # allow wall to be passable for a time or not
var explosive = false # can explode and destroy the player
var timer # our timer, counts down as time goes on
var timePassed = 0.0 # to track the elapsed time

signal wall_disappeared(wall)
signal timer_updated(time_left)

func _ready():
	if randf() < GLOBALS.wallPassableChance:
		passable = true
	
	if passable:
		COLLISION_SHAPE_BASE.disabled = true
	elif GLOBALS.playerIsGhost:
		COLLISION_SHAPE_BASE.disabled = true
	else:
		COLLISION_SHAPE_BASE.disabled = false
	
	if randf() < GLOBALS.wallLerpScaleChance:
		lerpScale = true
	
	SPRITE_BASE.modulate = colorSpriteBase
	LABEL_TIME_LEFT.modulate = colorTimeLeftLabel
	
	var collision_shape = COLLISION_SHAPE_BASE.shape
	if collision_shape != null:
		var shape_size = Vector2(collision_shape.extents.x * 2, collision_shape.extents.y * 2)
		self.scale = GLOBALS.cellSize / shape_size
		scaleOriginal = scale
	else:
		self.scale = GLOBALS.wallFallbackScale
		scaleOriginal = scale
	
	timer = Timer.new()
	timer.wait_time = lifeTime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()

func _process(delta):
	timePassed += delta
	update_passable_state()
	
	if timer.time_left > 0:
		emit_signal("timer_updated", timer.time_left)
		
		# DEBUGGING (REMOVE FOR RELEASE)
		if LABEL_TIME_LEFT != null:
			var formatted_time_left = "%*.*f"
			LABEL_TIME_LEFT.text = str(formatted_time_left % [0, 0, timer.time_left])

func _physics_process(_delta):
	if GLOBALS.playerIsGhost:
		COLLISION_SHAPE_BASE.disabled = true
	else:
		COLLISION_SHAPE_BASE.disabled = false
	
	if lerpScale:
		# sin functions oscillate between -1 and 1
		# so, to get around this we need to add 1 then divide by 2 to shift our value to the right
		# this ensures we oscillate between 0 and 1
		# now, we want to oscillate between 25 - 100% the default scale
		# so, we do "0.10 + 0.90 * ...", these 2 #'s need to add up to 1
		var scale_factor = 0.10 + 0.90 * (1.0 + sin(timePassed * GLOBALS.wallLerpScaleSpeed * PI * 2)) / 2.0
		scale = scaleOriginal * scale_factor

func update_passable_state():
	if passable:
		if timePassed < (lifeTime / 2.0):
			COLLISION_SHAPE_BASE.disabled = true
			SPRITE_BASE.modulate = colorSpritePassable
			LABEL_TIME_LEFT.modulate = colorTimeLeftPassableLable
		else:
			COLLISION_SHAPE_BASE.disabled = false
			SPRITE_BASE.modulate = colorSpriteBase
			LABEL_TIME_LEFT.modulate = colorTimeLeftLabel

func _on_timeout():
	emit_signal("wall_disappeared", self)
	queue_free()
