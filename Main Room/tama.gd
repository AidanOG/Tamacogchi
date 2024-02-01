extends CharacterBody2D
class_name Tama

@export var speed = 100.0
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity = 15000
@export var explosion_power = 50
var direction
var grabbed
var falling
var falling_fast
var requesting_sleep
var requesting_ill
var screen_size
var game_over = false

@export_group("Dependencies")
@export var idle_timer: Timer
@export var meander_timer: Timer
@export var pet_timer: Timer
@export var dizzy_timer: Timer
@export var sleep_timer: Timer
@export var sleep_request_timeout_timer: Timer
@export var eat_timer: Timer
@export var ill_treatment_timer: Timer
@export var explode_area: Area2D
@export var explode_area_shape: CollisionShape2D
@export var explosion_dropoff_curve: Curve

@export var sleep_request: Area2D
@export var ill_request: Area2D

@export var thunk_sound: AudioStreamPlayer

signal successful_pet
signal dropped
signal sleep_request_missed
signal sleep_finished
signal eat_finished
signal ill_treatment_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	idle_timer.start()
	print("IdleTimer Started 1")
	grabbed = false
	falling = false
	falling_fast = false
	requesting_sleep = false
	requesting_ill = false
	sleep_request.hide()
	ill_request.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	#print("on floor:", is_on_floor())
	#print("falling:", falling)
	#print("\n")
	#if velocity.y != 0:
		#print(velocity.y)
	if grabbed == false:
		velocity.x = 0
		if idle_timer.get_time_left() != 0:
			velocity.x = 0
		elif meander_timer.get_time_left() != 0:
			#print("Moving!")
			if direction == 0:
				velocity.x += 1
			else:
				velocity.x -= 1
			if velocity.length() > 0:
				velocity = velocity * speed
		if not is_on_floor():
			velocity.y += gravity * delta
			velocity.x = 0
			if grabbed == false:
				falling = true
		move_and_slide()
	elif grabbed == true:
		#print("He is grabbed!")
		pet_timer.stop()
		idle_timer.stop()
		meander_timer.stop()
		position = get_viewport().get_mouse_position().clamp(Vector2.ZERO, screen_size)

	if falling == true && not is_on_floor() && velocity.y >= 3000:
		falling_fast = true

	if falling == true && is_on_floor() && falling_fast == true:
		falling = false
		falling_fast = false
		pet_timer.stop()
		idle_timer.stop()
		meander_timer.stop()
		dizzy_timer.start()
		dropped.emit()
		thunk_sound.play()
		print("OOOOOOOOOOOOMPH")
	elif falling == true && is_on_floor() && falling_fast == false:
		falling = false
		pet_timer.stop()
		if dizzy_timer.get_time_left() == 0:
			idle_timer.start()
			print("IdleTimer Started 2")

func explode_nearby():
	for body in explode_area.get_overlapping_bodies():
		if body is RigidBody2D:
			var direction = body.global_position - global_position
			var total_dist = (explode_area_shape.shape as CircleShape2D).radius
			var scale_factor = explosion_dropoff_curve.sample(global_position.distance_to(body.global_position) / total_dist)
			
			if direction.y > 0:
				direction.y *= -1
			
			body.apply_impulse(direction * explosion_power * scale_factor)

func _on_meander_timer_timeout():
	idle_timer.set_wait_time(randf_range(2.0, 10.0))
	idle_timer.start()
	print("IdleTimer Started 3")

func _on_idle_timer_timeout():
	meander_timer.set_wait_time(randf_range(1.0, 2.0))
	direction = randi() % 2
	print("Direction: ", direction)
	meander_timer.start()
	print("MeanderTimer Started")

func _on_area_2d_mouse_entered():
	if grabbed == false && is_on_floor() && dizzy_timer.get_time_left() == 0 && sleep_timer.get_time_left() == 0 && eat_timer.get_time_left() == 0 && ill_treatment_timer.get_time_left() == 0:
		idle_timer.stop()
		meander_timer.stop()
		pet_timer.start()

func _on_area_2d_mouse_exited():
	if pet_timer.get_time_left() != 0:
		print("Pet unsuccessful.")
		pet_timer.stop()
		idle_timer.start()
		print("IdleTimer Started 4")

func _on_pet_timer_timeout():
	print("Pet successful.")
	pet_timer.stop()
	idle_timer.start()
	print("IdleTimer Started 5")
	successful_pet.emit()
	
func _on_dizzy_timer_timeout():
	print(":(")
	idle_timer.start()
	print("IdleTimer Started 6")
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.pressed && sleep_timer.get_time_left() == 0 && eat_timer.get_time_left() == 0 && game_over == false && ill_treatment_timer.get_time_left() == 0:
		#print("You just grabbed me!")
		grabbed = true
		falling = false
	if event is InputEventMouseButton && not event.pressed:
		#print("I'm free!")
		grabbed = false
		if is_on_floor():
			idle_timer.start()
			print("IdleTimer Started 7")

func _on_main_happiness_zero():
	pet_timer.stop()
	idle_timer.stop()
	meander_timer.stop()
	dizzy_timer.stop()
	sleep_timer.stop()
	ill_treatment_timer.stop()
	game_over = true

func _on_main_energy_low():
	idle_timer.stop()
	meander_timer.stop()
	requesting_sleep = true
	if requesting_ill == false:
		sleep_request.show()
	sleep_request_timeout_timer.start()

func _on_sleep_request_input_event(viewport, event, shape_idx):
	if requesting_sleep == true && dizzy_timer.get_time_left() == 0 && event is InputEventMouseButton && event.pressed && game_over == false && eat_timer.get_time_left() == 0 && ill_treatment_timer.get_time_left() == 0 && requesting_ill == false:
		sleep_request_timeout_timer.stop()
		sleep_timer.start()
		sleep_request.hide()
		idle_timer.stop()
		meander_timer.stop()
		requesting_sleep = false
		print("honk mimimi")

func _on_sleep_request_timeout_timer_timeout():
	sleep_request_missed.emit()
	print("missed sleep")
	requesting_sleep = false
	sleep_request.hide()
	if requesting_ill == false && ill_treatment_timer.get_time_left() == 0:
		idle_timer.start()
		print("IdleTimer Started 8")

func _on_sleep_timer_timeout():
	requesting_sleep = false
	idle_timer.start()
	print("IdleTimer Started 9")
	sleep_finished.emit()

func _on_hud_feed():
	if GameManager.food >= 1 && dizzy_timer.get_time_left() == 0 && sleep_timer.get_time_left() == 0 && eat_timer.get_time_left() == 0 && game_over == false && ill_treatment_timer.get_time_left() == 0 && requesting_ill == false:
		idle_timer.stop()
		meander_timer.stop()
		eat_timer.start()
		print("nom nom nom")

func _on_eat_timer_timeout():
	idle_timer.start()
	eat_finished.emit()
	print("yum")


func _on_main_ill():
	idle_timer.stop()
	meander_timer.stop()
	requesting_ill = true
	ill_request.show()
	sleep_request.hide()
	print("main ill")


func _on_illness_request_input_event(viewport, event, shape_idx):
	if requesting_ill == true && dizzy_timer.get_time_left() == 0 && event is InputEventMouseButton && event.pressed && game_over == false && eat_timer.get_time_left() == 0 && ill_treatment_timer.get_time_left() == 0:
		ill_treatment_timer.start()
		ill_request.hide()
		idle_timer.stop()
		meander_timer.stop()
		print("healing...")


func _on_ill_treatment_timer_timeout():
	requesting_ill = false
	if requesting_sleep == true:
		sleep_request.show()
	else:
		idle_timer.start()
	ill_treatment_finished.emit()
	print("thank you for super speed healing me")
