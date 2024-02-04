extends Node

@export_group("Dependencies")
@export var fruit_scene: PackedScene
@export var hazard_scene: PackedScene
@export var super_fruit_scene: PackedScene
@export var fruit_catch_hud: FruitCatchHUD
@export var game_timer: Timer
@export var fruit_timer: Timer
@export var phase_one_timer: Timer
@export var phase_two_timer: Timer
@export var fruit_spawn_location: PathFollow2D
@export var fruit_container: Node2D
@export var instructions_music: AudioStreamPlayer
@export var game_music: AudioStreamPlayer

var score
var final_food_gain
var game_started = false
var fruit_probability

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	final_food_gain = 0
	instructions_music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(game_started == true):
		fruit_catch_hud.update_time_remaining(floor(game_timer.get_time_left()))

func _on_fruit_catch_tama_hit():
	fruit_timer.stop()
	game_timer.stop()
	for child in fruit_container.get_children():
		child.queue_free()
	game_music.stop()
	await get_tree().create_timer(1.0).timeout
	final_food_gain = floor(float(score)/20.0)
	GameManager.food += final_food_gain
	GameManager.happiness -= GameManager.happiness_loss_lose_fruit_catch
	if GameManager.happiness < 0:
		GameManager.happiness = 0
	instructions_music.play()

func _on_fruit_timer_timeout():
	var fruit
	fruit_probability = randf_range(0, 1.0)
	
	if phase_one_timer.get_time_left() != 0:
		print("phase 1 fruit!")
		if fruit_probability <= 0.8: 
			fruit = fruit_scene.instantiate()
		else:
			fruit = hazard_scene.instantiate()
	elif phase_two_timer.get_time_left() != 0:
		print("phase 2 fruit!")
		if fruit_probability <= 0.75:
			fruit = fruit_scene.instantiate()
		elif fruit_probability <= 0.8:
			fruit = super_fruit_scene.instantiate()
			print("super!")
		else:
			fruit = hazard_scene.instantiate()
	else:
		print("phase 3 fruit!")
		if fruit_probability <= 0.5:
			fruit = fruit_scene.instantiate()
		elif fruit_probability <= 0.8:
			fruit = super_fruit_scene.instantiate()
			print("super!")
		else:
			fruit = hazard_scene.instantiate()

	# Choose a random location on Path2D.
	fruit_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	fruit.position = fruit_spawn_location.position

	# Spawn the mob by adding it to the Main scene.
	fruit_container.add_child(fruit)

func _on_phase_one_timer_timeout():
	fruit_timer.set_wait_time(0.25)
	phase_two_timer.start()
	game_music.pitch_scale = 1.2

func _on_phase_two_timer_timeout():
	fruit_timer.set_wait_time(0.1)
	game_music.pitch_scale = 1.5

func _on_game_timer_timeout():
	for child in fruit_container.get_children():
		child.queue_free()
	fruit_timer.stop()
	game_music.stop()
	await get_tree().create_timer(1.0).timeout
	final_food_gain = floor(float(score)/10.0)
	GameManager.food += final_food_gain
	GameManager.happiness += GameManager.happiness_gain_win_fruit_catch
	if GameManager.happiness > 100:
		GameManager.happiness = 100
	instructions_music.play()

func _on_fruit_catch_hud_start_game():
	fruit_timer.start()
	game_timer.start()
	phase_one_timer.start()
	game_started = true
	instructions_music.stop()
	game_music.play()

func _on_fruit_catch_tama_catch():
	score += 1
	fruit_catch_hud.update_score(score)

func _on_fruit_catch_tama_super_catch():
	print("YAAAAAAAAAAAAAY")
	score += 3
	fruit_catch_hud.update_score(score)
