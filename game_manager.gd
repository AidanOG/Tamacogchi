extends Node

var happiness
@export var happiness_start = 80.0

var energy
@export var energy_start = 80.0

var food
@export var food_start = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	happiness = happiness_start
	energy = energy_start
	food = food_start


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
