extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity = 1000
var game_over = false
var game_complete = false
var game_started = false

signal catch
signal hit


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if game_over == false && game_complete == false && game_started == true:
		# Handle jump.
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = 0

	move_and_slide()

func _on_area_2d_area_entered(area):
	catch.emit()
	print(area.name)
	if area is Fruit:
		print("this is fruit")
	#hit.emit()
	#game_over = true
	#$CollisionShape2D.set_deferred("disabled", true)

func _on_game_timer_timeout():
	game_complete = true

func _on_fruit_catch_hud_start_game():
	game_started = true
