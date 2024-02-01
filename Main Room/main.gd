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
@export var base_energy_loss_time = 0.5
@export var energy_loss_time = 0.5
var next_low_energy
var low_energy_signal_emitted = false

@export var hunger_loss_time = 1.0
@export var hunger_gain_feed = 30.0

@export_group("Dependencies")
@export var main_hud: MainHUD
@export var happiness_timer: Timer
@export var energy_timer: Timer
@export var sleep_request_downtime: Timer
@export var hunger_timer: Timer

signal happiness_zero
signal energy_low

# Called when the node enters the scene tree for the first time.
func _ready():
	#happiness = happiness_start
	#energy = energy_start
	next_low_energy = randi_range(5, 25)
	main_hud.update_happiness(GameManager.happiness)
	main_hud.update_energy(GameManager.energy)
	happiness_timer.start()
	energy_timer.start()
	hunger_timer.start()
	
	main_hud.update_food(GameManager.food)
	main_hud.update_hunger(GameManager.hunger)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.happiness <= 0:
		happiness_timer.stop()
		energy_timer.stop()
		hunger_timer.stop()
		happiness_zero.emit()
	if GameManager.energy <= next_low_energy && sleep_request_downtime.get_time_left() == 0 && GameManager.happiness > 0 && low_energy_signal_emitted == false:
		print("My energy low!")
		low_energy_signal_emitted = true
		energy_low.emit()
	
	energy_loss_time = base_energy_loss_time + (base_energy_loss_time * (((100.0 - GameManager.energy) / 10.0) + 0))
	# print(energy_loss_time)

func _on_happiness_timer_timeout():
	GameManager.happiness-=happiness_loss_time
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	main_hud.update_happiness(GameManager.happiness)

func _on_tama_successful_pet():
	GameManager.happiness+=happiness_gain_pet
	if GameManager.happiness > 100:
		GameManager.happiness = 100
	main_hud.update_happiness(GameManager.happiness)
	
func _on_energy_timer_timeout():
	GameManager.energy-=energy_loss_time
	if GameManager.energy < 0:
		GameManager.energy = 0
	main_hud.update_energy(GameManager.energy)

func _on_tama_dropped():
	GameManager.happiness-=happiness_loss_drop
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	main_hud.update_happiness(GameManager.happiness)

func _on_tama_sleep_request_missed():
	GameManager.happiness -=happiness_loss_sleep_missed
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	main_hud.update_happiness(GameManager.happiness)
	sleep_request_downtime.set_wait_time(randf_range(10, 20))
	sleep_request_downtime.start()
	next_low_energy = randi_range(5, 25)
	low_energy_signal_emitted = false

func _on_tama_sleep_finished():
	GameManager.energy = 100
	main_hud.update_energy(GameManager.energy)
	GameManager.happiness+=happiness_gain_sleep
	if GameManager.happiness >= 100:
		GameManager.happiness = 100
	main_hud.update_happiness(GameManager.happiness)
	low_energy_signal_emitted = false

func _on_hunger_timer_timeout():
	GameManager.hunger-=hunger_loss_time
	if GameManager.hunger < 0:
		GameManager.hunger = 0
	main_hud.update_hunger(GameManager.hunger)

func _on_tama_eat_finished():
	GameManager.food -= 1
	main_hud.update_food(GameManager.food)
	GameManager.hunger += hunger_gain_feed
	if GameManager.hunger > 100:
		GameManager.hunger = 100
	main_hud.update_hunger(GameManager.hunger)
