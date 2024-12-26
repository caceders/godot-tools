extends Node

const MIN_STILL_TIME = .5
const MAX_STILL_TIME = 20
const MAX_STRAFE_RADIUS = 50
const ACCEPTABLE_DISTANCE_TO_STRAFE_POSITION = 1

enum State {IDLE,
            STRAFING,
            HUNTING,
            CHARGING,
            ATTACKING,
            DYING,
            DEAD,
}


enum Direction {
            LEFT,
            RIGHT,
}

@export var entity: TopDownEntity2D
@export var animated_sprite_controller : AnimatedSprite2DController
@export var detection_area: Area2D
@export var attack_area: Area2D


var _stand_still_timer : Timer
var _active_state = State.IDLE
var _last_movement_direction = Direction.LEFT

var _strafe_position : Vector2

func _ready():
    _stand_still_timer = Timer.new()
    _stand_still_timer.one_shot = true
    add_child(_stand_still_timer)
    animated_sprite_controller.play_base_animation("enemyIdleLeft")


func _process(_delta):
    match _active_state:
        State.IDLE:
            if _stand_still_timer.time_left == 0:
                enter_state(State.STRAFING)
                
        State.STRAFING:

            var vector_to_strafe_position = _strafe_position - entity.position
            entity.direction = vector_to_strafe_position.normalized()

            if entity.direction.x < 0:
                animated_sprite_controller.play_base_animation("enemyWalkLeft")
                _last_movement_direction = Direction.LEFT
            else:
                animated_sprite_controller.play_base_animation("enemyWalkRight")
                _last_movement_direction = Direction.RIGHT

            if vector_to_strafe_position.length() < ACCEPTABLE_DISTANCE_TO_STRAFE_POSITION:
                enter_state(State.IDLE)

        State.HUNTING:
            pass
            
        State.CHARGING:
            pass
            
        State.ATTACKING:
            pass
            
        State.DYING:
            pass
            
        State.DEAD:
            pass
            


func enter_state(state: State):

    exit_state(_active_state)
    _active_state = state

    match state:
        State.IDLE:

            entity.direction = Vector2.ZERO

            if _last_movement_direction == Direction.LEFT:
                animated_sprite_controller.play_base_animation("enemyIdleLeft")
            if _last_movement_direction == Direction.RIGHT:
                animated_sprite_controller.play_base_animation("enemyIdleRight")
            _stand_still_timer.start(randf_range(MIN_STILL_TIME, MAX_STILL_TIME))
            _stand_still_timer.paused = false
            
        State.STRAFING:
            # Pick a random spot nearby and walk to
            var strafe_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
            _strafe_position = strafe_direction * randf_range(0, MAX_STRAFE_RADIUS)
            
        State.HUNTING:
            pass
            
        State.CHARGING:
            pass
            
        State.ATTACKING:
            pass
            
        State.DYING:
            pass
            
        State.DEAD:
            pass
            


func exit_state(state: State):
    match state:
        State.IDLE:
            pass
            
        State.STRAFING:
            pass
            
        State.HUNTING:
            pass
            
        State.CHARGING:
            pass
            
        State.ATTACKING:
            pass
            
        State.DYING:
            pass
            
        State.DEAD:
            pass
            


func _target_in_sight():
    pass


func _target_in_attack_range():
    pass
