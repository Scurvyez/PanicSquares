extends Node # pause.gd script

@onready var LABEL_PAUSE_GAME = get_node("/root/Game/pause_menu/pause_label")

var colorLabelText = Color8(242, 242, 242, 255)

func _ready():
	LABEL_PAUSE_GAME.set("theme_override_colors/font_color", colorLabelText)
	LABEL_PAUSE_GAME.visible = false

func _process(_delta):
	if LABEL_PAUSE_GAME.visible:
		LABEL_PAUSE_GAME.visible = false

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		pause_game()
	
func pause_game():
	LABEL_PAUSE_GAME.visible = true
	get_tree().paused = true
