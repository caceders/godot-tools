class_name Strafer extends Node2D

const MIN_DISTANCE_TO_DESIRED_POSITION = 0.1

enum StrafeState{
	IDLE,
	WALKING,
}

enum StrafeCentrumType{
	ENTITY_POSITION,
	SET_POSITION,
}

@export var entity: TopDownEntity2D

@export var enabled: bool = true

@export var strafe_centrum_type: StrafeCentrumType = StrafeCentrumType.ENTITY_POSITION

@export var min_stand_still_time: float = 1
@export var max_stand_still_time: float = 5

@export var min_strafe_distance: float = 10
@export var max_strafe_distance: float = 50

@export var strafe_weight: Vector2 = Vector2(0, 0)
@export var strafe_centrum_position: Vector2 = Vector2(0, 0)

var _active_state: StrafeState = StrafeState.IDLE
var _stand_still_timer : Timer
var _desired_position: Vector2 = Vector2(0 ,0)

func _ready():
	_stand_still_timer = Timer.new()
	_stand_still_timer.one_shot = true
	add_child(_stand_still_timer)

func _process(_delta):
	if not enabled:
		return
	match _active_state:
		StrafeState.IDLE:
			if _stand_still_timer.time_left == 0:
				_enter_state(StrafeState.WALKING)
				return
			return

		StrafeState.WALKING:
			if (global_position - _desired_position).length() < MIN_DISTANCE_TO_DESIRED_POSITION:
				_enter_state(StrafeState.IDLE)
				return
			entity.direction = global_position.direction_to(_desired_position)
			return

func _enter_state(state: StrafeState):
	if not enabled:
		return
	_active_state = state
	match _active_state:
		StrafeState.IDLE:
			entity.direction = Vector2(0,0)
			_stand_still_timer.start(randf_range(min_stand_still_time, max_stand_still_time))
			return
		StrafeState.WALKING:
			var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			var distance = randf_range(min_strafe_distance, max_strafe_distance)
			match strafe_centrum_type:
				StrafeCentrumType.ENTITY_POSITION:
					_desired_position = global_position + (direction * distance) + strafe_weight
					return
				StrafeCentrumType.SET_POSITION:
					_desired_position = strafe_centrum_position + direction * distance + strafe_weight
					return
			return
					

func enable():
	enabled = true

func disable():
	enabled = false
