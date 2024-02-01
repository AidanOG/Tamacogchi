extends Node

var happiness
@export var happiness_start = 80.0
@export var happiness_gain_win_fruit_catch = 30.0
@export var happiness_loss_lose_fruit_catch = 20.0

var energy
@export var energy_start = 100.0
@export var energy_to_play_fruit_catch = 30.0

var food
@export var food_start = 3

var hunger
@export var hunger_start = 100.0

var wellness
@export var wellness_start = 75.0


# Called when the node enters the scene tree for the first time.
func _ready():
	happiness = happiness_start
	energy = energy_start
	food = food_start
	hunger = hunger_start
	wellness = wellness_start


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
