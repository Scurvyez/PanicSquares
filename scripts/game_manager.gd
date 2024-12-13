extends Node # game_manager.gd script

@onready var ScreenManager = get_node("/root/Game/screen_manager")
@onready var CanvasGroup_MUI = get_node("/root/Game/game_manager/CanvasGroup_Main_UI")
@onready var Lab_HS = get_node("/root/Game/game_manager/CanvasGroup_Main_UI/highscore_label")
@onready var Lab_S = get_node("/root/Game/game_manager/CanvasGroup_Main_UI/score_label")
@onready var Lab_T = get_node("/root/Game/game_manager/timer_label")

var colorLabelText = Color8(242, 242, 242, 255)
var savePath = "user://highscore.save" # path for save file
var highScore = 0 # our highscore
var currentScore = 0 # our current score

signal score_updated(currentScore)
signal score_factor_of_10(currentScore)


func _on_game_ready():
	_on_load()
	
	# timer label setup
	var timer_init_x = ScreenManager.ScreenSize.x / 2
	var timer_init_y = (ScreenManager.ScreenSize.y / ScreenManager.GridSize.y) * 0.25
	Lab_T.position = Vector2(timer_init_x / timer_init_x, timer_init_y)
	
	# get all labels in our canvas group for the main UI group
	# space them out evenly within the top row of our grid
	CanvasGroup_MUI.position.y = (ScreenManager.ScreenSize.y / ScreenManager.GridSize.y) * 0.04
	for i in CanvasGroup_MUI.get_children():
		i.position.y *= 1.0
	
	Lab_HS.set("theme_override_colors/font_color", colorLabelText)
	Lab_S.set("theme_override_colors/font_color", colorLabelText)
	
	Lab_HS.text = "Highscore: " + str(highScore)
	Lab_S.text = "Score: 0"
	emit_signal("score_updated", currentScore)


func _on_ready():
	pass


func _process(_delta):
	if Globals.playerHearts < 0:
		call_deferred("_reload_scene")


func _reload_scene():
	get_tree().reload_current_scene()


func add_point():
	currentScore += 1
	
	Lab_S.text = "Score: " + str(currentScore)
	emit_signal("score_updated", currentScore)
	
	if currentScore % 20 == 0:
		emit_signal("score_factor_of_10", currentScore)
		
	if currentScore <= highScore:
		Lab_HS.text = "Highscore: " + str(highScore)
	else:
		highScore = currentScore
		Lab_HS.text = "Highscore: " + str(highScore)
		
	_on_save()


func update_timer_label(time_left):
	var formatted_time_left = "%*.*f"
	Lab_T.set("theme_override_colors/font_color", colorLabelText)
	Lab_T.text = str(formatted_time_left % [3, 2, time_left])


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

