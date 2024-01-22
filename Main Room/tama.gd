extends CharacterBody2D

@export var speed = 100.0
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity = 15000
var direction
var grabbed
var falling
var falling_fast
var requesting_sleep
var screen_size
var game_over = false

signal successful_pet
signal dropped
signal sleep_request_missed
signal sleep_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$IdleTimer.start()
	print("IdleTimer Started 1")
	grabbed = false
	falling = false
	falling_fast = false
	requesting_sleep = false
	$SleepRequest.hide()

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
		if $IdleTimer.get_time_left() != 0:
			velocity.x = 0
		elif $MeanderTimer.get_time_left() != 0:
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
		$PetTimer.stop()
		$IdleTimer.stop()
		$MeanderTimer.stop()
		position = get_viewport().get_mouse_position().clamp(Vector2.ZERO, screen_size)

	if falling == true && not is_on_floor() && velocity.y >= 3000:
		falling_fast = true

	if falling == true && is_on_floor() && falling_fast == true:
		falling = false
		falling_fast = false
		$PetTimer.stop()
		$IdleTimer.stop()
		$MeanderTimer.stop()
		$DizzyTimer.start()
		dropped.emit()
		$ThunkSound.play()
		print("OOOOOOOOOOOOMPH")
	elif falling == true && is_on_floor() && falling_fast == false:
		falling = false
		$PetTimer.stop()
		if $DizzyTimer.get_time_left() == 0:
			$IdleTimer.start()
			print("IdleTimer Started 2")

func _on_meander_timer_timeout():
	$IdleTimer.set_wait_time(randf_range(2.0, 10.0))
	$IdleTimer.start()
	print("IdleTimer Started 3")

func _on_idle_timer_timeout():
	$MeanderTimer.set_wait_time(randf_range(1.0, 2.0))
	direction = randi() % 2
	print("Direction: ", direction)
	$MeanderTimer.start()
	print("MeanderTimer Started")

func _on_area_2d_mouse_entered():
	if grabbed == false && is_on_floor() && $DizzyTimer.get_time_left() == 0 && $SleepTimer.get_time_left() == 0:
		$IdleTimer.stop()
		$MeanderTimer.stop()
		$PetTimer.start()

func _on_area_2d_mouse_exited():
	if $PetTimer.get_time_left() != 0:
		print("Pet unsuccessful.")
		$PetTimer.stop()
		$IdleTimer.start()
		print("IdleTimer Started 4")

func _on_pet_timer_timeout():
	print("Pet successful.")
	$PetTimer.stop()
	$IdleTimer.start()
	print("IdleTimer Started 5")
	successful_pet.emit()
	
func _on_dizzy_timer_timeout():
	print("Fucker :(")
	$IdleTimer.start()
	print("IdleTimer Started 6")
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.pressed && $SleepTimer.get_time_left() == 0 && game_over == false:
		#print("You just grabbed me!")
		grabbed = true
		falling = false
	if event is InputEventMouseButton && not event.pressed:
		#print("I'm free!")
		grabbed = false
		if is_on_floor():
			$IdleTimer.start()
			print("IdleTimer Started 7")

func _on_main_happiness_zero():
	$PetTimer.stop()
	$IdleTimer.stop()
	$MeanderTimer.stop()
	$DizzyTimer.stop()
	$SleepTimer.stop()
	game_over = true

func _on_main_energy_low():
	$IdleTimer.stop()
	$MeanderTimer.stop()
	requesting_sleep = true
	$SleepRequest.show()
	$SleepRequestTimeoutTimer.start()

func _on_sleep_request_input_event(viewport, event, shape_idx):
	if requesting_sleep == true && $DizzyTimer.get_time_left() == 0 && event is InputEventMouseButton && event.pressed && game_over == false:
		$SleepRequestTimeoutTimer.stop()
		$SleepTimer.start()
		$SleepRequest.hide()
		$IdleTimer.stop()
		$MeanderTimer.stop()
		requesting_sleep = false
		print("honk mimimi")

func _on_sleep_request_timeout_timer_timeout():
	sleep_request_missed.emit()
	requesting_sleep = false
	$SleepRequest.hide()
	$IdleTimer.start()
	print("IdleTimer Started 8")

func _on_sleep_timer_timeout():
	requesting_sleep = false
	$IdleTimer.start()
	print("IdleTimer Started 9")
	sleep_finished.emit()