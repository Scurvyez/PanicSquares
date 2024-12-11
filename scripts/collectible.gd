extends Area2D # collectible.gd script

@onready var Globals = get_node("/root/Game/globals")
@onready var Game = get_node("/root/Game")
@onready var G_M = get_node("/root/Game/game_manager")
@onready var Col_Util = get_node("/root/Game/color_util")
@onready var Spr_B = get_node("sprite_base")
@onready var Spr_TB = get_node("sprite_time_booster")
@onready var Coll_SB = get_node("collision_shape_base")

## all time vars in seconds
var is_tb = false # does this instance offer more time?
var lifetime # (seconds before the collectible disappears) (lose if it does)
var life_tb_amount
var timer # counts down as time goes on
var time_passed = 0.0

signal collectible_collected(collectible)
signal timer_updated(time_left)
signal spawn_enemy()
signal spawn_life_pickup()
signal spawn_ghost_physics_powerup()
signal collectible_timed_out()

func _ready():
	if (
			randf() < Globals.enemySpawnChance 
			and G_M.currentScore >= Globals.enemySpawnScoreThreshold
	):
		emit_signal("spawn_enemy")
	
	if (
			not Globals.lifePickupIsActive 
			and Globals.playerHearts < Globals.playerMaxHearts
	):
		if (
				randf() < Globals.heartSpawnChance 
				and G_M.currentScore >= Globals.heartSpawnScoreThreshold
		):
			emit_signal("spawn_life_pickup")
	
	if (
			not Globals.ghostPhysicsPowerUpIsActive 
			and randf() < Globals.ghostPhysicsPowerupSpawnChance 
			and G_M.currentScore >= Globals.ghostPhysicsPowerupSpawnScoreThreshold 
			and not Globals.playerIsGhost
	):
		emit_signal("spawn_ghost_physics_powerup")
	
	self.rotation = 0
	
	set_initial_shader_params()
	set_is_timebooster()
	set_lifetime()
	set_timer()
	set_process(true)


func _process(delta):
	time_passed += delta
	
	if timer.time_left > 0:
		emit_signal("timer_updated", timer.time_left)
		G_M.update_timer_label(timer.time_left)
		
		var coll_shape = Coll_SB.shape
		if coll_shape != null:
			var rot_angle = (time_passed * 0.5) * Globals.collectibleRotationSpeed
			self.rotation_degrees = rot_angle
		
		set_alpha_via_lifetime()


## CHANGE FOR RELEASE, TO BE MORE FLUID
func set_lifetime():
	if G_M.currentScore <= 50:
		lifetime = 20.0
	elif G_M.currentScore > 50 and G_M.currentScore <= 150:
		lifetime = 10.0
	elif G_M.currentScore > 150:
		lifetime = 5.0
		
	if is_tb:
		life_tb_amount = lifetime * 0.5
		lifetime += life_tb_amount


func set_is_timebooster():
	if randf() < Globals.collectibleTimeBoosterChance:
		is_tb = true
		Spr_TB.material.set_shader_parameter("color_base", Col_Util.Color_Pl_B)
	else:
		Spr_TB.material.set_shader_parameter("color_base", Col_Util.Color_Hidden)


func set_initial_shader_params():
	Spr_B.material.set_shader_parameter("color_base", Col_Util.Color_Co_B)


func set_alpha_via_lifetime():
	var lifetime_percentage = timer.time_left / lifetime
	var cur_color = Spr_B.material.get_shader_parameter("color_base")
	
	if lifetime_percentage < 0.25:
		cur_color.a = 0.25
	elif lifetime_percentage < 0.5:
		cur_color.a = 0.5
	elif lifetime_percentage < 0.75:
		cur_color.a = 0.75
	else:
		cur_color.a = 1.0
	
	Spr_B.material.set_shader_parameter("color_base", cur_color)


func set_timer():
	timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()


func _on_body_entered(body):
	if body.name == "player":
		if body.has_method("_on_collect_trigger"):
			body._on_collect_trigger()
			
		emit_signal("collectible_collected", self)
		G_M.add_point()
		queue_free()


func _on_timeout():
	Globals.playerHearts -= 1
	Game.update_health_sprites()
	emit_signal("collectible_timed_out", self)
	queue_free()

