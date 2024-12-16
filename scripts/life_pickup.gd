extends Area2D

## --------------------------------/+\--------------------------------
## life_pickup.gd
## 
## This script houses the logic for our life pickups. Grabbing one 
## will give back a single lost life (heart).
##
## - Spawn randomly after a certain point threshold has been hit
## - Limited lifetime
## --------------------------------\+/--------------------------------

@onready var Game = get_node("/root/Game")
@onready var ColorUtil = get_node("/root/Game/color_util")
@onready var Spr_B = get_node("sprite_base")
@onready var Coll_PB = get_node("collision_polygon_base")

var lifetime = randf_range(5.0, 10.0) # random lifetime between 5 and 10 seconds
var timer # (in seconds) counts down as time goes on
var time_passed = 0.0 # (in seconds)

signal life_pickup_collected


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	self.rotation = 0
	
	set_initial_shader_params()
	set_timer();
	set_process(true)


func _process(delta):
	time_passed += delta

	if timer.time_left > 0:
		var polygon = Coll_PB.polygon
		if polygon.size() > 0:
			var rot_angle = (time_passed * 0.5) * Globals.heartRotationSpeed
			self.rotation_degrees = rot_angle


func _on_body_entered(body):
	if (
			body.name == "player" 
			and Globals.playerHearts <= Globals.playerMaxHearts
	):
		if body.has_method("_on_lp_pickup_trigger"):
			body._on_lp_pickup_trigger()
			
		emit_signal("life_pickup_collected", self)
		queue_free()


func set_initial_shader_params():
	Spr_B.material.set_shader_parameter("color_base", ColorUtil.Color_Lp_B)


func set_timer():
	timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_lifetime_expired"))
	add_child(timer)
	timer.start()


func _on_lifetime_expired():
	Globals.lifePickupIsActive = false
	queue_free()

