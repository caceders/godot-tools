extends Node

@export var entity : TopDownEntity2D

func _process(delta):
	if Input.is_action_just_pressed("impulse"):
		entity.add_impulse(Vector2(randf_range(-200, 200), randf_range(-200, 200)))
