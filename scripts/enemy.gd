extends CharacterBody2D # enemy.gd script

@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var Player = get_node("/root/Game/player")
@onready var ColorUtil = get_node("/root/Game/color_util")
@onready var Spr_B = get_node("sprite_base")
@onready var Spr_T = get_node("sprite_tail")
@onready var Area = get_node("area")
@onready var Sh_C = get_node("shape_cast")

var lifetime = randf_range(10.0, 45.0) # random lifetime between 10 and 45 seconds
var timer_rd = 0.0 # timer for each movement change
var timer # timer for the enemy's lifetime

var target_vel = Vector2.ZERO # for smooth turning
var turn_speed = 5.0 # turn rate

signal player_touched_enemy


func _ready():
	randomize()
	Area.connect("body_entered", Callable(self, "_on_body_entered"))
	Globals.enemyCell = (
		((position - ScreenManager.CellSize / 2) / ScreenManager.CellSize).round()
	)
	Sh_C.shape.radius = Globals.enemyDetectRadius
	
	set_timer()
	set_initial_shader_params()


func _process(delta):
	if (
			Player and Sh_C.is_colliding() 
			and Sh_C.get_collider(0) == Player
	):
		chase_player(delta)
	else:
		random_move(delta)
	
	# Smoothly adjust the velocity toward the target
	velocity = velocity.lerp(target_vel, turn_speed * delta)
	
	# Apply movement and check for wall collisions
	move_and_slide()
	if collision_detected():
		handle_wall_collision()
	
	screen_wrap()
	
	# Update current enemy cell positions
	# make an array if we have > 1
	Globals.enemyCell = (
		((position - ScreenManager.CellSize / 2) / ScreenManager.CellSize).round()
	)


func _physics_process(_delta):
	# Set rotation to face the direction of movement or towards the player
	if (
			Player and Sh_C.is_colliding() 
			and Sh_C.get_collider(0) == Player
	):
		rotation = (Player.position - position).angle()
	else:
		# Face the direction of movement
		if velocity.length() > 0:
			rotation = velocity.angle()
		else:
			rotation = velocity.angle()


func chase_player(_delta):
	var direction_to_player = (Player.position - position).normalized()
	target_vel = direction_to_player * Globals.enemyChaseSpeed


func random_move(delta):
	timer_rd -= delta
	if timer_rd <= 0:
		# Change direction
		var angle = randf() * PI * 2
		target_vel = (
			Vector2(cos(angle), sin(angle)).normalized() * Globals.enemySpeed
		)
		# Set a new timer for direction change
		timer_rd = randf_range(0.5, 4.5)


func screen_wrap():
	var top_limit = ScreenManager.ScreenSize.y / ScreenManager.GridSize.y
	position.x = wrapf(position.x, 0, ScreenManager.ScreenSize.x)
	position.y = wrapf(position.y, top_limit, ScreenManager.ScreenSize.y)


func collision_detected() -> bool:
	# Check for collisions during move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			if collision.get_collider().is_class("StaticBody2D"):
				return true
	return false


func handle_wall_collision():
	target_vel = -target_vel
	# Optionally, add some random rotation to the direction


func set_initial_shader_params():
	Spr_B.material.set_shader_parameter("color_base", ColorUtil.Color_En_B)
	Spr_T.material.set_shader_parameter("color_base", ColorUtil.Color_En_B)
	Spr_B.material.set_shader_parameter("color_oscil", ColorUtil.Color_En_Os)
	Spr_T.material.set_shader_parameter("color_oscil", ColorUtil.Color_En_Os)


func set_timer():
	timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_lifetime_expired"))
	add_child(timer)
	timer.start()


func _on_body_entered(body):
	if body.name == "player":
		emit_signal("player_touched_enemy")
		queue_free()


func _on_lifetime_expired():
	# When the lifetime timer expires, despawn the enemy
	queue_free()

