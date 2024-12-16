extends Node

## --------------------------------/+\--------------------------------
## pause_game.gd
## 
## This script contains the logic for when the player pauses the game.
##
## - Displays / hides certain ui elements on pause
## - Pauses & unpauses the current game
## --------------------------------\+/--------------------------------

@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var ColorUtil = get_node("/root/Game/color_util")
@onready var Tac_TO_Base = get_node("/root/Game/pause_menu/tactical_timeout")
@onready var Tac_TO_Bg = get_node("/root/Game/pause_menu/tactical_timeout_bg")
@onready var Keys_Base = get_node("/root/Game/pause_menu/controls_ui/keys_base")
@onready var Keys_Overlay = get_node("/root/Game/pause_menu/controls_ui/keys_overlay")
@onready var Keys_Base_Bg = get_node("/root/Game/pause_menu/controls_ui/keys_base_bg")

var col_lab_text = Color8(242, 242, 242, 255)
var is_paused = false

# Fade and texture logic
var fade_duration = 1.0  # Duration for fade-in/out
var fade_time = 0.0  # Tracks the current fade cycle progress
var fading_out = true  # Whether the overlay is fading out
var current_texture_index = 0  # Current texture index
var key_textures = []  # Array of textures for cycling


func _ready():
	set_initial_ui()
	load_key_textures()

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if is_paused:
			resume_game()
		else:
			pause_game()
	
	if is_paused:
		handle_fade_logic(delta)


func pause_game():
	is_paused = true
	set_ui_on_pause()
	get_tree().paused = true
	reset_fade()


func resume_game():
	is_paused = false
	set_ui_on_resume()
	get_tree().paused = false
	reset_ui()


func set_initial_ui():
	Tac_TO_Base.visible = false
	Tac_TO_Bg.visible = false
	Keys_Base.visible = false
	Keys_Overlay.visible = false
	Keys_Base_Bg.visible = false
	
	Keys_Overlay.modulate = col_lab_text
	Keys_Overlay.modulate = Color.BLACK
	
	Keys_Base.scale = Vector2(0.5, 0.5)
	Keys_Overlay.scale = Vector2(0.5, 0.5)
	
	var vert_offset = 200.0
	var padding = Vector2(0.06, 0.175)
	var width = ScreenManager.ScreenSize.x
	var height = ScreenManager.ScreenSize.y
	
	Tac_TO_Base.position = Vector2(width / 2, height / 2)
	Tac_TO_Bg.position = Vector2(width / 2, height / 2)
	Keys_Base.position = Vector2(width / 2, (height / 2) + vert_offset)
	Keys_Base_Bg.position = Keys_Base.position
	Keys_Overlay.position = Vector2(width / 2, (height / 2) + vert_offset)
	
	Tac_TO_Bg.scale += padding
	Keys_Base_Bg.scale += padding


func set_ui_on_pause():
	Tac_TO_Base.visible = true
	Tac_TO_Bg.visible = true
	Keys_Base.visible = true
	Keys_Overlay.visible = true
	Keys_Base_Bg.visible = true
	Keys_Overlay.texture = key_textures[current_texture_index]


func set_ui_on_resume():
	Tac_TO_Base.visible = false
	Tac_TO_Bg.visible = false
	Keys_Base.visible = false
	Keys_Overlay.visible = false
	Keys_Base_Bg.visible = false


func load_key_textures():
	# Preload the textures into an array
	key_textures = [
		preload("res://textures/controls_ui_keys_wasd.png"),
		preload("res://textures/controls_ui_keys_arrows.png")
	]


func reset_fade():
	# Reset fading logic
	fade_time = 0.0
	fading_out = true
	Keys_Overlay.modulate.a = 1.0  # Start fully visible


func reset_ui():
	# Reset UI elements and alpha
	Keys_Overlay.modulate.a = 1.0


func handle_fade_logic(delta):
	# Manage fade-in/out and texture swapping
	fade_time += delta
	if fading_out:
		Keys_Overlay.modulate.a = 1.0 - (fade_time / fade_duration)
		if fade_time >= fade_duration:
			fade_time = 0.0
			fading_out = false
			change_texture()
	else:
		Keys_Overlay.modulate.a = fade_time / fade_duration
		if fade_time >= fade_duration:
			fade_time = 0.0
			fading_out = true


func change_texture():
	# Switch to the next texture in the array
	current_texture_index = (current_texture_index + 1) % key_textures.size()
	Keys_Overlay.texture = key_textures[current_texture_index]
