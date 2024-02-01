extends RigidBody2D
class_name Poop

@export var poop_angle: Vector2 = Vector2(0, 180)
@export var poop_power: Vector2 = Vector2(100, 500)

# Called when the node enters the scene tree for the first time.
func _ready():
	var angle = deg_to_rad(randf_range(poop_angle.x, poop_angle.y))
	var direction = Vector2.RIGHT.rotated(-angle)
	var power = randf_range(poop_power.x, poop_power.y)
	apply_impulse(direction * power)



func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.pressed && GameManager.game_over == false:
		queue_free()
		GameManager.poop_count -= 1
