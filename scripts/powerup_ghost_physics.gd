extends Area2D  # powerup_ghost_physics.gd script

@onready var ColorUtil = get_node("/root/Game/color_util")
@onready var Spr_B = get_node("sprite_base")
@onready var Coll_SB = get_node("collision_shape_base")

var lifetime = randf_range(5.0, 10.0) # random lifetime between 5 and 10 seconds
var timer # our timer, counts down as time goes on
var time_passed = 0.0 # time passed

signal ghost_physics_powerup_collected


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	self.rotation = 0
	
	set_initial_shader_params()
	set_timer()
	set_process(true)


func _process(delta):
	time_passed += delta

	if timer.time_left > 0:
		var coll_shape = Coll_SB.shape
		if coll_shape != null:
			var rot_angle = (time_passed * 0.5) * Globals.ghostPhysicsPowerupRotationSpeed
			self.rotation_degrees = rot_angle


func set_initial_shader_params():
	Spr_B.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_Gp)


func set_timer():
	timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_lifetime_expired"))
	add_child(timer)
	timer.start()

func _on_body_entered(body):
	if body.name == "player":
		emit_signal("ghost_physics_powerup_collected", self)
		Globals.playerIsGhost = true
		
		queue_free()


func _on_lifetime_expired():
	Globals.ghostPhysicsPowerUpIsActive = false
	queue_free()

