class_name ChaserEvader extends Node2D

const TEST_DISTANCE_INTERVAL = 10

enum BehaviorType{
	CHASE,
	EVADE,
}

@export var vision: Vision
@export var entity: TopDownEntity2D
@export var enabled: bool = true
@export var navigation_agent : NavigationAgent2D
## Chase groups
@export var chase : Array[String] = []
## Evade groups
@export var evade : Array[String] = []
## If both a group to chase and one to evade is in sight what to prioritize?
@export var prioritize: BehaviorType = BehaviorType.CHASE

var _behavior : BehaviorType = BehaviorType.CHASE
var _body_to_react_to : Node2D

func _ready():
	vision.body_entered.connect(_on_body_entered_vision)
	vision.body_exited.connect(_on_body_exited_vision)

func _physics_process(delta):
	if _body_to_react_to and not _body_to_react_to in vision.get_overlapping_bodies():
		_body_to_react_to = null
		entity.direction = Vector2.ZERO
	
	if enabled and _body_to_react_to:
		if _behavior == BehaviorType.EVADE:
			# Run away until body is out of sight - or as far as possible
			var distance_reduction = 0
			var direction = _body_to_react_to.global_position.direction_to(global_position)
			var distance = _body_to_react_to.global_position.distance_to(global_position) + vision.distance - distance_reduction
			navigation_agent.target_position = global_position + direction * distance
			while not navigation_agent.is_target_reachable():
				distance_reduction += TEST_DISTANCE_INTERVAL
				direction = _body_to_react_to.global_position.direction_to(global_position)
				distance = _body_to_react_to.global_position.distance_to(global_position) + vision.distance - distance_reduction
				navigation_agent.target_position = global_position + direction * distance
			entity.direction = global_position.direction_to(navigation_agent.get_next_path_position())

		elif _behavior == BehaviorType.CHASE:
			# Run to body - or as near as possible
			var distance_reduction = 0
			var direction = global_position.direction_to(_body_to_react_to.global_position)
			var distance = global_position.distance_to(_body_to_react_to.global_position) - distance_reduction
			navigation_agent.target_position = global_position + direction * distance
			while not navigation_agent.is_target_reachable(): 
				distance_reduction += TEST_DISTANCE_INTERVAL
				direction = global_position.direction_to(_body_to_react_to.global_position)
				distance = global_position.distance_to(_body_to_react_to.global_position) - distance_reduction
				navigation_agent.target_position = global_position + direction * distance
			entity.direction = global_position.direction_to(navigation_agent.get_next_path_position())
	

func _on_body_entered_vision(body):
	if prioritize == BehaviorType.CHASE:
		# Chase
		for group in chase:
			if _body_to_react_to:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.CHASE
			elif group in body.get_groups():
				_behavior = BehaviorType.CHASE
				_body_to_react_to = body
				return
		# Evade
		for group in evade:
			if _body_to_react_to:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.EVADE
			elif group in body.get_groups():
				_behavior = BehaviorType.EVADE
				_body_to_react_to = body
				return
	
	elif prioritize == BehaviorType.EVADE:
		# Evade
		for group in evade:
			if _body_to_react_to:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.EVADE
			elif group in body.get_groups():
				_behavior = BehaviorType.EVADE
				_body_to_react_to = body
				return

		# Chase
		for group in chase:
			if _body_to_react_to:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.CHASE
			elif group in body.get_groups():
				_behavior = BehaviorType.CHASE
				_body_to_react_to = body
				return

func _on_body_exited_vision(body):
	if body == _body_to_react_to:
		entity.direction = Vector2.ZERO

func enable():
	enabled = true

func disable():
	enabled = false
