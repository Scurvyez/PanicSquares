extends StaticBody2D # wall.gd script

@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var Col_Util = get_node("/root/Game/color_util")
@onready var Spr_B = get_node("sprite_base")
@onready var Coll_SB = get_node("collision_shape_base")
@onready var Lab_TL = get_node("DEBUG_time_left_label")

var colorTimeLeftLabel = Color8(0, 0, 0, 255) # time left label color
var colorTimeLeftPassableLable = Color8(242, 242, 242, 255) # time left passable label color

var lifetime = randf_range(10, 99) # (seconds before the wall disappears)
var scaleOriginal # original wall scale
var lerpscale = false # oscillate walls' scale or not
var passable = false # allow wall to be passable for a time or not
var explosive = false # can explode and destroy the player
var timer # our timer, counts down as time goes on
var time_passed = 0.0 # to track the elapsed time

signal wall_disappeared(wall)
signal timer_updated(time_left)

func _ready():
	if randf() < Globals.wallPassableChance:
		passable = true
	
	if randf() < Globals.wallLerpScaleChance:
		lerpscale = true
	
	var collision_shape = Coll_SB.shape
	if collision_shape != null:
		var shape_size = Vector2(collision_shape.extents.x * 2, collision_shape.extents.y * 2)
		self.scale = ScreenManager.CellSize / shape_size
		scaleOriginal = scale
	else:
		self.scale = Globals.wallFallbackScale
		scaleOriginal = scale
	
	Lab_TL.modulate = colorTimeLeftLabel
	
	ensure_unique_shader_material()
	set_initial_shader_params()
	set_timer()


func _process(delta):
	time_passed += delta
	
	if passable:
		update_passable_state()
	elif Globals.playerIsGhost:
		Coll_SB.disabled = true
		Spr_B.material.set_shader_parameter("color_base", Col_Util.Color_Wa_P)
	elif not passable and not Globals.playerIsGhost:
		Coll_SB.disabled = false
		Spr_B.material.set_shader_parameter("color_base", Col_Util.Color_Wa_B)
	
	if timer.time_left > 0:
		emit_signal("timer_updated", timer.time_left)
		
		# DEBUGGING (REMOVE FOR RELEASE? kinda like it)
		if Lab_TL != null:
			var formatted_time_left = "%*.*f"
			Lab_TL.text = str(formatted_time_left % [0, 0, timer.time_left])


func _physics_process(_delta):
	#if GLOBALS.playerIsGhost:
		#COLLISION_SHAPE_BASE.disabled = true
	#else:
		#COLLISION_SHAPE_BASE.disabled = false
	
	if lerpscale:
		# sin functions oscillate between -1 and 1
		# so, to get around this we need to add 1 then divide by 2 to shift our value to the right
		# this ensures we oscillate between 0 and 1
		# now, we want to oscillate between 25 - 100% the default scale
		# so, we do "0.10 + 0.90 * ...", these 2 #'s need to add up to 1
		var scale_factor = 0.10 + 0.90 * (1.0 + sin(time_passed * Globals.wallLerpScaleSpeed * PI * 2)) / 2.0
		scale = scaleOriginal * scale_factor


func set_initial_shader_params():
	Spr_B.material.set_shader_parameter("color_base", Col_Util.Color_Wa_B)


func ensure_unique_shader_material():
	# Check if the sprite already has a ShaderMaterial, if not, create one
	if not Spr_B.material is ShaderMaterial:
		Spr_B.material = ShaderMaterial.new()
		Spr_B.material.shader = load("res://shaders/wallColor.gdshader")


func set_timer():
	timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()


func update_passable_state():
	if (
			time_passed < (lifetime / 2.0) 
			or Globals.playerIsGhost
	):
		Coll_SB.disabled = true
		Spr_B.material.set_shader_parameter("color_base", Col_Util.Color_Wa_P)
		Lab_TL.modulate = colorTimeLeftPassableLable
	else:
		Coll_SB.disabled = false
		Spr_B.material.set_shader_parameter("color_base", Col_Util.Color_Wa_B)
		Lab_TL.modulate = colorTimeLeftLabel


func _on_timeout():
	emit_signal("wall_disappeared", self)
	queue_free()

