extends Area2D  # life_pickup.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var GAME = get_node("/root/Game")
@onready var SPRITE_BASE = get_node("sprite_base")
@onready var COLLISION_POLYGON_BASE = get_node("collision_polygon_base")

var spriteBaseColor = Color8(255, 255, 102, 255) # base color

var lifeTime = randf_range(5.0, 10.0) # random lifetime between 5 and 10 seconds
var timer # our timer, counts down as time goes on
var timePassed = 0.0 # time passed

signal life_pickup_collected

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
		var polygon = COLLISION_POLYGON_BASE.polygon
		if polygon.size() > 0:
			var rot_angle = (timePassed * 0.5) * GLOBALS.heartRotationSpeed
			self.rotation_degrees = rot_angle

func _on_body_entered(body):
	if body.name == "player" and GLOBALS.playerHearts <= GLOBALS.playerMaxHearts:
		emit_signal("life_pickup_collected", self)
		queue_free()

func _on_lifetime_expired():
	GAME.lifePickupIsActive = false
	queue_free()
