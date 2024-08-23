extends Area2D  # powerup_ghost_physics.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var GAME = get_node("/root/Game")
@onready var SPRITE_BASE = get_node("sprite_base")
@onready var COLLISION_SHAPE_BASE = get_node("collision_shape_base")

var spriteBaseColor = Color8(255, 179, 102, 255) # base color

var lifeTime = randf_range(5.0, 10.0) # random lifetime between 5 and 10 seconds
var timer # our timer, counts down as time goes on
var timePassed = 0.0 # time passed

signal ghost_physics_powerup_collected

func _ready():
	self.rotation = 0
	SPRITE_BASE.modulate = spriteBaseColor
	
	timer = Timer.new()
	timer.wait_time = lifeTime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_lifetime_expired"))
	add_child(timer)
	timer.start()
	
	connect("body_entered", Callable(self, "_on_body_entered"))  # Connect the signal

	set_process(true)

func _process(delta):
	timePassed += delta

	if timer.time_left > 0:
		var coll_shape = COLLISION_SHAPE_BASE.shape
		if coll_shape != null:
			var rot_angle = (timePassed * 0.5) * GLOBALS.ghostPhysicsPowerupRotationSpeed
			self.rotation_degrees = rot_angle

func _on_body_entered(body):
	if body.name == "player":
		emit_signal("ghost_physics_powerup_collected", self)
		GLOBALS.playerIsGhost = true
		
		queue_free()

func _on_lifetime_expired():
	GLOBALS.ghostPhysicsPowerUpIsActive = false
	queue_free()
