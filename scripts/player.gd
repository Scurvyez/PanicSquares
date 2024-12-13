extends CharacterBody2D # player.gd script

@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var ColorUtil = get_node("/root/Game/color_util")
@onready var Spr_B = get_node("sprite_base")
@onready var Spr_T = get_node("sprite_tail")


func _ready():
	position = ScreenManager.ScreenSize / 2
	Globals.playerCell = ((position - ScreenManager.CellSize / 2) / ScreenManager.CellSize).round()
	
	set_initial_shader_params()


func _physics_process(delta):
	var moveDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if moveDir != Vector2.ZERO:
		var targetVel = moveDir * Globals.playerSpeed
		velocity = velocity.move_toward(targetVel, Globals.playerAccel * delta)
		var targetRot = moveDir.angle()
		rotation = lerp_angle(rotation, targetRot, Globals.playerRotationSpeed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Globals.playerDecel * delta)
	
	move_and_slide()
	screen_wrap()


func _process(_delta):
	# Update player's current cell position
	# "- ScreenManager.CellSize / 2" to offset the position by half in both x and y directions
	Globals.playerCell = ((position - ScreenManager.CellSize / 2) / ScreenManager.CellSize).round()
	
	if Globals.playerCollIsLerping:
		collect_effect(_delta)
	
	if Globals.playerLpCollIsLerping:
		collect_lp_effect(_delta)
	
	if Globals.playerIsGhost:
		set_ghost_shader_params()
	else:
		set_default_shader_params()


func screen_wrap():
	var top_limit = ScreenManager.ScreenSize.y / ScreenManager.GridSize.y
	position.x = wrapf(position.x, 0, ScreenManager.ScreenSize.x)
	position.y = wrapf(position.y, top_limit, ScreenManager.ScreenSize.y)


func set_initial_shader_params():
	Spr_B.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_B)
	Spr_T.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_B)
	Spr_B.material.set_shader_parameter("color_collect_mid", ColorUtil.Color_Co_B)
	Spr_T.material.set_shader_parameter("color_collect_mid", ColorUtil.Color_Co_B)
	Spr_B.material.set_shader_parameter("color_lp", ColorUtil.Color_Lp_B)
	Spr_T.material.set_shader_parameter("color_lp", ColorUtil.Color_Lp_B)

func set_default_shader_params():
	Spr_B.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_B)
	Spr_T.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_B)

func set_ghost_shader_params():
	Spr_B.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_Gp)
	Spr_T.material.set_shader_parameter("color_base", ColorUtil.Color_Pl_Gp)

func _on_collect_trigger():
	Globals.playerCollIsLerping = true


func _on_lp_pickup_trigger():
	Globals.playerLpCollIsLerping = true


func collect_effect(delta):
	Spr_B.material.set_shader_parameter("enable_collect_lerp", true)
	Spr_T.material.set_shader_parameter("enable_collect_lerp", true)
	Globals.playerCollLerpTimer += delta
	var t = Globals.playerCollLerpTimer / Globals.playerCollLerpDuration
	Spr_B.material.set_shader_parameter("lerp_time", t)
	Spr_T.material.set_shader_parameter("lerp_time", t)
	
	if t >= 1.0:
		Globals.playerCollIsLerping = false
		Globals.playerCollLerpTimer = 0.0
		Spr_B.material.set_shader_parameter("enable_collect_lerp", false)
		Spr_T.material.set_shader_parameter("enable_collect_lerp", false)


func collect_lp_effect(delta):
	Spr_B.material.set_shader_parameter("enable_lp_lerp", true)
	Spr_T.material.set_shader_parameter("enable_lp_lerp", true)
	Globals.playerCollLerpTimer += delta
	var t = Globals.playerCollLerpTimer / Globals.playerCollLerpDuration
	Spr_B.material.set_shader_parameter("lerp_time", t)
	Spr_T.material.set_shader_parameter("lerp_time", t)
	
	if t >= 1.0:
		Globals.playerLpCollIsLerping = false
		Globals.playerCollLerpTimer = 0.0
		Spr_B.material.set_shader_parameter("enable_lp_lerp", false)
		Spr_T.material.set_shader_parameter("enable_lp_lerp", false)


func _on_draw():
	pass

