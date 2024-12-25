extends Node

@export var entity : TopDownEntity2D

func _process(delta):
	if Input.is_action_just_pressed("impulse"):
		entity.add_impulse(Vector2(randf_range(-2000, 2000), randf_range(-200, 200)))

	var direction = Input.get_vector("left", "right", "up", "down")
	print(direction)
	entity.direction = direction
	print(entity.direction)
	
