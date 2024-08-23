extends Node # game_manager.gd script

@onready var GLOBALS = get_node("/root/Game/globals")
@onready var CANVASGROUP_MAIN_UI = get_node("/root/Game/game_manager/CanvasGroup_Main_UI")
@onready var LABEL_HIGHSCORE = get_node("/root/Game/game_manager/CanvasGroup_Main_UI/highscore_label")
@onready var LABEL_SCORE = get_node("/root/Game/game_manager/CanvasGroup_Main_UI/score_label")
@onready var LABEL_TIMER = get_node("/root/Game/game_manager/timer_label")

var colorLabelText = Color8(242, 242, 242, 255)
var savePath = "user://highscore.save" # path for save file
var highScore = 0 # our highscore
var currentScore = 0 # our current score

signal score_updated(currentScore)
signal score_factor_of_10(currentScore)

func _on_game_ready():
	_on_load()
	
	# timer label setup
	var timer_init_x = GLOBALS.screenSize.x / 2
	var timer_init_y = (GLOBALS.screenSize.y / GLOBALS.gridSize.y) * 0.25
	LABEL_TIMER.position = Vector2(timer_init_x / timer_init_x, timer_init_y)
	
	# get all labels in our canvas group for the main UI group
	# space them out evenly within the top row of our grid
	CANVASGROUP_MAIN_UI.position.y = (GLOBALS.screenSize.y / GLOBALS.gridSize.y) * 0.04
	for i in CANVASGROUP_MAIN_UI.get_children():
		i.position.y *= 1.0
	
	LABEL_HIGHSCORE.set("theme_override_colors/font_color", colorLabelText)
	LABEL_SCORE.set("theme_override_colors/font_color", colorLabelText)
	
	LABEL_HIGHSCORE.text = "Highscore: " + str(highScore)
	LABEL_SCORE.text = "Score: 0"
	emit_signal("score_updated", currentScore)

func _on_ready():
	pass

func _process(_delta):
	if GLOBALS.playerHearts < 0:
		call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()

func add_point():
	currentScore += 1
	
	LABEL_SCORE.text = "Score: " + str(currentScore)
	emit_signal("score_updated", currentScore)
	
	if currentScore % 20 == 0:
		emit_signal("score_factor_of_10", currentScore)
		
	if currentScore <= highScore:
		LABEL_HIGHSCORE.text = "Highscore: " + str(highScore)
	else:
		highScore = currentScore
		LABEL_HIGHSCORE.text = "Highscore: " + str(highScore)
		
	_on_save()

func update_timer_label(time_left):
	var formatted_time_left = "%*.*f"
	LABEL_TIMER.set("theme_override_colors/font_color", colorLabelText)
	LABEL_TIMER.text = str(formatted_time_left % [3, 2, time_left])

func save_data():
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_var(highScore)

func load_data():
	if FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		highScore = file.get_var(highScore)
	else:
		highScore = 0

func _on_save():
	save_data()

func _on_load():
	load_data()
