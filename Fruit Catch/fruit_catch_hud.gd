extends CanvasLayer
class_name FruitCatchHUD

@export_group("Dependencies")
@export var ready_countdown_label: Label
@export var time_remaining_label: Label
@export var score_label: Label
@export var ready_countdown_timer: Timer
@export var instructions_label: Label
@export var start_button: Button
@export var end_label: Label
@export var game_over_label: Label
@export var return_button: Button

signal start_game
var game_started = false
var score_display = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_countdown_label.hide()
	time_remaining_label.hide()
	score_label.hide()
	end_label.hide()
	game_over_label.hide()
	return_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(game_started == true):
		ready_countdown_label.text = (str(floor(ready_countdown_timer.get_time_left())))

func _on_start_button_pressed():
	ready_countdown_label.show()
	time_remaining_label.show()
	score_label.show()
	instructions_label.hide()
	start_button.hide()
	ready_countdown_timer.start()
	game_started = true

func _on_ready_countdown_timer_timeout():
	ready_countdown_label.hide()
	start_game.emit()

func update_time_remaining(time):
	time_remaining_label.text = str(time)
	
func update_score(score):
	score_label.text = str(score)
	score_display = score

func _on_game_timer_timeout():
	await get_tree().create_timer(1.0).timeout
	end_label.text = "Nice hustle! \nWe scored %d points! \nThat earns us %d food! Bon appétit! Well, for me, anyway." % [score_display, floor(float(score_display)/10.0)]
	end_label.show()
	return_button.show()

func _on_return_button_pressed():
	get_tree().change_scene_to_packed(SceneManager.main_scene)

func _on_fruit_catch_tama_hit():
	await get_tree().create_timer(1.0).timeout
	game_over_label.text = "Ouch... \nW-We scored %d points... \nBut I dropped some, so we only get %d food... \nCould've been worse, right?" % [score_display, floor(float(score_display)/20.0)]
	game_over_label.show()
	return_button.show()
