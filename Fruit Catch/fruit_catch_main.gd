extends Node

@export var fruit_scene: PackedScene
@export var hazard_scene: PackedScene

var score
var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(game_started == true):
		$FruitCatchHUD.update_time_remaining(str(ceil($GameTimer.get_time_left())))


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Main Room/main.tscn")

func _on_fruit_catch_tama_hit():
	$FruitTimer.stop()
	$GameTimer.stop()


func _on_fruit_timer_timeout():
	print("here's a fruit")
	var fruit = fruit_scene.instantiate()

	# Choose a random location on Path2D.
	var fruit_spawn_location = get_node("FruitPath/FruitSpawnLocation")
	fruit_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	fruit.position = fruit_spawn_location.position

	# Spawn the mob by adding it to the Main scene.
	add_child(fruit)

func _on_phase_one_timer_timeout():
	$FruitTimer.set_wait_time(0.33)
	$PhaseTwoTimer.start()

func _on_phase_two_timer_timeout():
	$FruitTimer.set_wait_time(0.25)

func _on_game_timer_timeout():
	$FruitTimer.stop()

func _on_fruit_catch_hud_start_game():
	$FruitTimer.start()
	$GameTimer.start()
	$PhaseOneTimer.start()
	game_started = true
