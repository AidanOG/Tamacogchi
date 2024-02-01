extends CanvasLayer
class_name MainHUD

@export_group("Dependencies")
@export var message: Label

@export var happiness_bar: ProgressBar
@export var energy_bar: ProgressBar
@export var hunger_bar: ProgressBar
@export var wellness_bar: ProgressBar

@export var food_label: Label

@export var fruit_catch_button: Button
@export var feed_button: Button


signal feed

# Called when the node enters the scene tree for the first time.
func _ready():
	message.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_happiness(happiness):
	happiness_bar.value = happiness

func update_energy(energy):
	energy_bar.value = energy
	
func update_food(food):
	food_label.text = str(food)
	
func update_hunger(hunger):
	hunger_bar.value = hunger

func update_wellness(wellness):
	wellness_bar.value = wellness

func _on_main_happiness_zero():
	message.show()
	fruit_catch_button.hide()
	

func _on_fruit_catch_button_pressed():
	#get_tree().quit()
	if GameManager.energy >= GameManager.energy_to_play_fruit_catch && GameManager.wellness > 0:
		GameManager.energy -= GameManager.energy_to_play_fruit_catch
		get_tree().change_scene_to_packed(SceneManager.fruit_catch_scene)


func _on_feed_button_pressed():
	feed.emit()
