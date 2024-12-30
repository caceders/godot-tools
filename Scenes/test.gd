extends Node

@export var enemy : Node2D

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		enemy.get_node("Health").remove_from_amount(10)
	
