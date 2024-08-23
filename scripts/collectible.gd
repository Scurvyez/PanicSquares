extends Area2D # collectible.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var GAME = get_node("/root/Game")
@onready var GAME_MANAGER = get_node("/root/Game/game_manager")
@onready var SPRITE_BASE = get_node("sprite_base")
@onready var SPRITE_TIME_BOOSTER = get_node("sprite_time_booster")
@onready var COLLISION_SHAPE_BASE = get_node("collision_shape_base")

var spriteHiddenColor = Color8(0, 0, 0, 0) # hidden color
var spriteBaseColor = Color8(102, 255, 255, 255) # base color
var spriteHalflifeColor = Color8(102, 255, 255, 205) # halflife color
var spriteQuarterlifeColor = Color8(102, 255, 255, 155) # quarter-life color
var spriteTimeBoosterColor = Color8(102, 255, 140, 255) # time booster color

var isTimeBooster = false # is time booster
var lifeTime # (seconds before the collectible disappears) (lose if it does)
var lifeTimeBoostAmount # lifetime boost amount
var timer # our timer, counts down as time goes on
var timePassed = 0.0 # time passed

signal collectible_collected(collectible)
signal timer_updated(time_left)
signal spawn_enemy()
signal spawn_life_pickup()
signal spawn_ghost_physics_powerup()
signal collectible_timed_out() # New signal for timeout

func _ready():
	if randf() < GLOBALS.enemySpawnChance and GAME_MANAGER.currentScore >= GLOBALS.enemySpawnScoreThreshold:
		emit_signal("spawn_enemy")
	
	if not GLOBALS.lifePickupIsActive and GLOBALS.playerHearts < GLOBALS.playerMaxHearts:
		if randf() < GLOBALS.heartSpawnChance and GAME_MANAGER.currentScore >= GLOBALS.heartSpawnScoreThreshold:
			emit_signal("spawn_life_pickup")
	
	if not GLOBALS.ghostPhysicsPowerUpIsActive and randf() < GLOBALS.ghostPhysicsPowerupSpawnChance and GAME_MANAGER.currentScore >= GLOBALS.ghostPhysicsPowerupSpawnScoreThreshold and !GLOBALS.playerIsGhost:
		emit_signal("spawn_ghost_physics_powerup")
	
	if randf() < GLOBALS.collectibleTimeBoosterChance:
		isTimeBooster = true
		SPRITE_TIME_BOOSTER.modulate = spriteTimeBoosterColor
	else:
		SPRITE_TIME_BOOSTER.modulate = spriteHiddenColor
		
	self.rotation = 0
	SPRITE_BASE.modulate = spriteBaseColor
	
	set_lifetime()
	
	timer = Timer.new()
	timer.wait_time = lifeTime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()

	set_process(true)

func _process(delta):
	timePassed += delta

	if timer.time_left > 0:
		emit_signal("timer_updated", timer.time_left)
		GAME_MANAGER.update_timer_label(timer.time_left)
		
		var coll_shape = COLLISION_SHAPE_BASE.shape
		if coll_shape != null:
			var rot_angle = (timePassed * 0.5) * GLOBALS.collectibleRotationSpeed
			self.rotation_degrees = rot_angle
		
		if timer.time_left < (lifeTime / 2):
			SPRITE_BASE.modulate = spriteHalflifeColor
			
		if timer.time_left < (lifeTime / 4):
			SPRITE_BASE.modulate = spriteQuarterlifeColor

# CHANGE FOR RELEASE, TO BE MORE FLUID
func set_lifetime():
	if GAME_MANAGER.currentScore <= 50:
		lifeTime = 20.0
	elif GAME_MANAGER.currentScore > 50 and GAME_MANAGER.currentScore <= 150:
		lifeTime = 10.0
	elif GAME_MANAGER.currentScore > 150:
		lifeTime = 5.0
		
	if isTimeBooster:
		lifeTimeBoostAmount = lifeTime * 0.5
		lifeTime += lifeTimeBoostAmount

func _on_body_entered(body):
	if body.name == "player":
		emit_signal("collectible_collected", self)
		GAME_MANAGER.add_point()
		queue_free()

func _on_timeout():
	GLOBALS.playerHearts -= 1
	GAME.update_health_sprites()
	emit_signal("collectible_timed_out", self) # Emit the timeout signal
	queue_free()
