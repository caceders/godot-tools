class_name ChaserEvader extends Node2D

enum BehaviorType{
	CHASE,
	EVADE,
}

@export var vision: Vision
@export var entity: TopDownEntity2D
@export var enabled: bool = true
@export var behavior: BehaviorType = BehaviorType.CHASE
@export var node_react_to: Node2D

func _process(_delta):
	if not enabled or node_react_to == null:
		return
	match behavior:
		BehaviorType.CHASE:
			entity.direction = global_position.direction_to(node_react_to.global_position)
			return
		BehaviorType.EVADE:
			entity.direction = node_react_to.global_position.direction_to(global_position)
			return

func enable():
	enabled = true

func disable():
	enabled = false
