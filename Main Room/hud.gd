extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Message.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_happiness(happiness):
	$HappinessBar.value = happiness

func update_energy(energy):
	$EnergyBar.value = energy

func _on_main_happiness_zero():
	$Message.show()
	$FruitCatchButton.hide()

func _on_fruit_catch_button_pressed():
	#get_tree().quit()
	get_tree().change_scene_to_file("res://Fruit Catch/fruit_catch_main.tscn")
