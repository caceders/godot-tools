@tool
class_name Vision extends Area2D
@export var distance = 100:
	set(value):
		if value < 0: distance = 0
		else: distance = value
		
	

func _physics_process(delta):
	if $CollisionShape2D.shape.radius != distance:
		var shape = CircleShape2D.new()
		shape.radius = distance
		$CollisionShape2D.shape = shape
	return
