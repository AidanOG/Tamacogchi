extends Node

@export_group("Dependencies")
@export var fruit_scene: PackedScene
@export var hazard_scene: PackedScene
@export var fruit_catch_hud: FruitCatchHUD
@export var game_timer: Timer
@export var fruit_timer: Timer
@export var phase_one_timer: Timer
@export var phase_two_timer: Timer
@export var fruit_spawn_location: PathFollow2D
@export var fruit_container: Node2D

var score
var game_started = false
var fruit_probability

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(game_started == true):
		fruit_catch_hud.update_time_remaining(ceil(game_timer.get_time_left()))

func _on_fruit_catch_tama_hit():
	fruit_timer.stop()
	game_timer.stop()

func _on_fruit_timer_timeout():
	print("here's a fruit")
	var fruit
	fruit_probability = randf_range(0, 1.0)
	if fruit_probability <= 0.8: 
		fruit = fruit_scene.instantiate()
	else:
		fruit = hazard_scene.instantiate()

	# Choose a random location on Path2D.
	fruit_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	fruit.position = fruit_spawn_location.position

	# Spawn the mob by adding it to the Main scene.
	fruit_container.add_child(fruit)

func _on_phase_one_timer_timeout():
	fruit_timer.set_wait_time(0.33)
	phase_two_timer.start()

func _on_phase_two_timer_timeout():
	fruit_timer.set_wait_time(0.25)

func _on_game_timer_timeout():
	for child in fruit_container.get_children():
		child.queue_free()
	fruit_timer.stop()

func _on_fruit_catch_hud_start_game():
	fruit_timer.start()
	game_timer.start()
	phase_one_timer.start()
	game_started = true

func _on_fruit_catch_tama_catch():
	score += 1
	fruit_catch_hud.update_score(score)
