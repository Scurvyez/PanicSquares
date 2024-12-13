extends Node # pause.gd script

@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var ColorUtil = get_node("/root/Game/color_util")
@onready var Lab_PG = get_node("/root/Game/pause_menu/pause_label")
@onready var Keys_Base = get_node("/root/Game/pause_menu/controls_ui/keys_base")
@onready var Keys_Overlay = get_node("/root/Game/pause_menu/controls_ui/keys_overlay")

var col_lab_text = Color8(242, 242, 242, 255)


func _ready():
	set_initial_ui()


func _process(_delta):
	if Lab_PG.visible:
		Lab_PG.visible = false
	if Keys_Base.visible:
		Keys_Base.visible = false
	if Keys_Overlay.visible:
		Keys_Overlay.visible = false


func _input(_event):
	if Input.is_action_just_pressed("pause"):
		pause_game()


func pause_game():
	set_ui_on_pause()


func set_initial_ui():
	Lab_PG.visible = false
	Keys_Base.visible = false
	Keys_Overlay.visible = false
	
	Lab_PG.set("theme_override_colors/font_color", col_lab_text)
	
	Keys_Overlay.modulate = col_lab_text
	Keys_Overlay.modulate = ColorUtil.Color_Heart
	
	Keys_Base.scale = Vector2(0.5, 0.5)
	Keys_Overlay.scale = Vector2(0.5, 0.5)
	
	var vert_offset = 200.0
	Keys_Base.position = Vector2(ScreenManager.ScreenSize.x / 2, (ScreenManager.ScreenSize.y / 2) + vert_offset)
	Keys_Overlay.position = Vector2(ScreenManager.ScreenSize.x / 2, (ScreenManager.ScreenSize.y / 2) + vert_offset)


func set_ui_on_pause():
	Lab_PG.visible = true
	Keys_Base.visible = true
	Keys_Overlay.visible = true
	
	get_tree().paused = true
