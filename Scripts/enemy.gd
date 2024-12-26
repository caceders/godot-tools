extends Node

enum State {IDLE,
            STRAFING,
            HUNTING,
            CHARGING,
            ATTACKING,
            DYING,
            DEAD,
}

@export var entity: TopDownEntity2D
@export var animated_sprite_controller : AnimatedSprite2DController

var _active_state = State.IDLE

func _process(_delta):
    match _active_state:
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

func exit_state(state: State):
    pass

func enter_state(state: State):
    pass
