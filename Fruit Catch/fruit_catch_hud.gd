extends CanvasLayer

signal start_game
var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReadyCountdownLabel.hide()
	$TimeRemainingLabel.hide()
	$ScoreLabel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(game_started == true):
		$ReadyCountdownLabel.text = (str(ceil($ReadyCountdownTimer.get_time_left())))


func _on_start_button_pressed():
	$ReadyCountdownLabel.show()
	$TimeRemainingLabel.show()
	$ScoreLabel.show()
	$InstructionsLabel.hide()
	$StartButton.hide()
	$ReadyCountdownTimer.start()
	game_started = true


func _on_ready_countdown_timer_timeout():
	$ReadyCountdownLabel.hide()
	start_game.emit()
	
	
func update_time_remaining(time):
	$TimeRemainingLabel.text = str(time)
