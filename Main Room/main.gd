extends Node

#var happiness
#@export var happiness_start = 80.0
@export var happiness_loss_time = 1.0
@export var happiness_gain_pet = 50.0
@export var happiness_loss_drop = 20.0
@export var happiness_gain_sleep = 10.0
@export var happiness_loss_sleep_missed = 10.0

#var energy
#@export var energy_start = 80.0
@export var energy_loss_time = 5.0
var next_low_energy
var low_energy_signal_emitted = false

signal happiness_zero
signal energy_low

# Called when the node enters the scene tree for the first time.
func _ready():
	#happiness = happiness_start
	#energy = energy_start
	next_low_energy = randi_range(5, 25)
	$HUD.update_happiness(GameManager.happiness)
	$HUD.update_energy(GameManager.energy)
	$HappinessTimer.start()
	$EnergyTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.happiness <= 0:
		$HappinessTimer.stop()
		$EnergyTimer.stop()
		happiness_zero.emit()
	if GameManager.energy <= next_low_energy && $SleepRequestDowntime.get_time_left() == 0 && GameManager.happiness > 0 && low_energy_signal_emitted == false:
		print("My energy low!")
		low_energy_signal_emitted = true
		energy_low.emit()

func _on_happiness_timer_timeout():
	GameManager.happiness-=happiness_loss_time
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	$HUD.update_happiness(GameManager.happiness)

func _on_tama_successful_pet():
	GameManager.happiness+=happiness_gain_pet
	if GameManager.happiness > 100:
		GameManager.happiness = 100
	$HUD.update_happiness(GameManager.happiness)
	
func _on_energy_timer_timeout():
	GameManager.energy-=energy_loss_time
	if GameManager.energy < 0:
		GameManager.energy = 0
	$HUD.update_energy(GameManager.energy)

func _on_tama_dropped():
	GameManager.happiness-=happiness_loss_drop
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	$HUD.update_happiness(GameManager.happiness)

func _on_tama_sleep_request_missed():
	GameManager.happiness -=happiness_loss_sleep_missed
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	$HUD.update_happiness(GameManager.happiness)
	$SleepRequestDowntime.set_wait_time(randf_range(10, 20))
	$SleepRequestDowntime.start()
	next_low_energy = randi_range(5, 25)
	low_energy_signal_emitted = false

func _on_tama_sleep_finished():
	GameManager.energy = 100
	$HUD.update_energy(GameManager.energy)
	GameManager.happiness+=happiness_gain_sleep
	if GameManager.happiness >= 100:
		GameManager.happiness = 100
	$HUD.update_happiness(GameManager.happiness)
	low_energy_signal_emitted = false
