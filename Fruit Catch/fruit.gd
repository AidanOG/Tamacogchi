extends Area2D

class_name Fruit

@export var fruit_gravity = 5
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	var fruit_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(fruit_types[randi() % fruit_types.size()])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	velocity.y += fruit_gravity * delta
	
	position += velocity

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
