extends Node

enum Direction {
    DIRECTION_LEFT,
    DIRECTION_RIGHT,
} 

@export var player_entity : TopDownEntity2D
@export var animated_sprite : AnimatedSprite2D

var _last_movement_direction: Direction = Direction.DIRECTION_LEFT

func _ready():
    animated_sprite.play("playerIdleLeft")


func _process(delta):
    var movement_dir = Input.get_vector("left", "right", "up", "down")
    player_entity.direction = movement_dir

    if player_entity.is_moving:
        if movement_dir.x < 0:
            _last_movement_direction = Direction.DIRECTION_LEFT
        if movement_dir.x > 0:
            _last_movement_direction = Direction.DIRECTION_RIGHT
    
    if _is_movement_just_pressed():
        if _last_movement_direction == Direction.DIRECTION_LEFT:
            animated_sprite.play("playerWalkLeft")
        if _last_movement_direction == Direction.DIRECTION_RIGHT:
            animated_sprite.play("playerWalkRight")
    
    elif _is_movement_just_released():
        if _last_movement_direction == Direction.DIRECTION_LEFT:
            animated_sprite.play("playerIdleLeft")
        if _last_movement_direction == Direction.DIRECTION_RIGHT:
            animated_sprite.play("playerIdleRight")

    if Input.is_action_just_pressed("attack"):
        if _last_movement_direction == Direction.DIRECTION_LEFT:
            animated_sprite.play("playerSpellLeft")
        if _last_movement_direction == Direction.DIRECTION_RIGHT:
            animated_sprite.play("playerSpellRight")

func _is_movement_just_pressed():
    return (
        Input.is_action_just_pressed("up") or
        Input.is_action_just_pressed("down") or
        Input.is_action_just_pressed("left") or
        Input.is_action_just_pressed("right")
        )

func _is_movement_just_released():
    return (
        Input.is_action_just_released("up") or
        Input.is_action_just_released("down") or
        Input.is_action_just_released("left") or
        Input.is_action_just_released("right")
        )